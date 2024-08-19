/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


import { audio } from '@kit.AudioKit';
import { avSession } from '@kit.AVSessionKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo, ReadOptions } from '@kit.CoreFileKit';
import { Logger } from '@ohos/utils';
import { AudioPlayerService, AudioPlayerStatus } from './AudioPlayerService';
import { TEMP_AUDIO_FILE_NAME } from './SpeechPlayerService';

const TAG = '[AudioRenderService]';

const DEFAULT_AUDIO_STREAM_INFO: audio.AudioStreamInfo = {
  // The current version of SpeechKit requires a fixed sampling rate 16000. Therefore, the player also uses 16000.
  samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_16000,
  channels: audio.AudioChannel.CHANNEL_1,
  sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
  encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
}

const DEFAULT_AUDIO_RENDERER_INFO: audio.AudioRendererInfo = {
  usage: audio.StreamUsage.STREAM_USAGE_MUSIC,
  rendererFlags: 0
}

const DEFAULT_AUDIO_RENDERER_OPTIONS: audio.AudioRendererOptions = {
  streamInfo: DEFAULT_AUDIO_STREAM_INFO,
  rendererInfo: DEFAULT_AUDIO_RENDERER_INFO
}

export class AudioRenderService {
  private renderer: audio.AudioRenderer | undefined = undefined;
  private renderBufferSize: number = 0;
  private static instance: AudioRenderService;

  public static getInstance(): AudioRenderService {
    if (!AudioRenderService.instance) {
      AudioRenderService.instance = new AudioRenderService();
    }
    return AudioRenderService.instance;
  }

  public writeDataCallback(buffer: ArrayBuffer) {
    let path = getContext().tempDir;
    let filePath = path + TEMP_AUDIO_FILE_NAME;
    // Check whether the file exists. If the file cannot be found, the program may break down.
    if (fileIo.accessSync(filePath)) {
      let file: fileIo.File = fileIo.openSync(filePath, fileIo.OpenMode.READ_ONLY);
      let options: ReadOptions = {
        offset: this.renderBufferSize,
        length: buffer.byteLength
      }
      const len = fileIo.readSync(file.fd, buffer, options);
      if (len > 0) {
        this.renderBufferSize += buffer.byteLength;
      } else {
        this.stopAudioRender();
      }
    }
  }

  public initAudioRenderInit(audioRendererOptions?: audio.AudioRendererOptions): Promise<void> {
    //callback function for listening to the audio stream written by audio render
    return audio.createAudioRenderer(audioRendererOptions ?? DEFAULT_AUDIO_RENDERER_OPTIONS).then(renderer => {
      this.renderer = renderer;
      if (this.renderer) {
        this.renderer.on('writeData', (buffer) => this.writeDataCallback(buffer));
      }
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `Failed to create audio renderer. Cause: ${err.message}.`);
      return;
    });
  }

  public startAudioRender() {
    if (this.renderer) {
      let stateGroup = [audio.AudioState.STATE_PREPARED, audio.AudioState.STATE_PAUSED, audio.AudioState.STATE_STOPPED];
      // Rendering starts if and only if the state is one of prepared, paused, and stopped.
      if (stateGroup.indexOf(this.renderer.state.valueOf()) === -1) {
        Logger.error(TAG, `Rendering starts if and only if the state is one of prepared, paused, and stopped.`);
        return;
      }
      // start audio renderer
      this.renderer.start((err: BusinessError) => {
        if (err) {
          Logger.error(TAG, `Failed to start audio renderer. Cause${err.message}.`);
          return;
        }
        AppStorage.setOrCreate<AudioPlayerStatus>('audioPlayerStatus', AudioPlayerStatus.PLAYING);
        Logger.info(TAG, 'Succeeded to start audio renderer.');
      });
      // listening audio renderer status change
      this.renderer.on('stateChange', (state: audio.AudioState) => {
        const audioPlayerService = AudioPlayerService.getInstance();
        if (state === audio.AudioState.STATE_PREPARED) {
          Logger.info(TAG, 'The audio render status changes: STATE_PREPARED');
        }
        if (state === audio.AudioState.STATE_RUNNING) {
          audioPlayerService.setSessionPlayState(avSession.PlaybackState.PLAYBACK_STATE_PLAY);
          Logger.info(TAG, 'The audio render status changes: STATE_RUNNING');
        }
        if (state === audio.AudioState.STATE_STOPPED) {
          audioPlayerService.setSessionPlayState(avSession.PlaybackState.PLAYBACK_STATE_STOP);
          // reset current buffer offset and remove temp file
          let path = getContext().tempDir;
          let filePath = path + TEMP_AUDIO_FILE_NAME;
          if (!fileIo.accessSync((filePath))) {
            return;
          }
          fileIo.unlinkSync(filePath);
          this.renderBufferSize = 0;
          this.renderer?.flush();
          AppStorage.setOrCreate<AudioPlayerStatus>('audioPlayerStatus', AudioPlayerStatus.IDLE);
          Logger.info(TAG, 'The audio render status changes: STATE_STOPPED');
        }
        if (state === audio.AudioState.STATE_RELEASED) {
          audioPlayerService.setSessionPlayState(avSession.PlaybackState.PLAYBACK_STATE_RELEASED);
          Logger.info(TAG, 'The audio render status changes: STATE_RELEASED');
        }
        if (state === audio.AudioState.STATE_PAUSED) {
          audioPlayerService.setSessionPlayState(avSession.PlaybackState.PLAYBACK_STATE_PAUSE);
          Logger.info(TAG, 'The audio render status changes: STATE_PAUSED');
        }
      });
    }
  }

  public pauseAudioRender() {
    if (this.renderer) {
      // The render can be paused only when it is in the running state.
      if (this.renderer.state.valueOf() !== audio.AudioState.STATE_RUNNING) {
        Logger.error(TAG, 'The render can be paused only when it is in the running state.');
        return;
      }
      // pause audio renderer
      this.renderer.pause((err: BusinessError) => {
        if (err) {
          Logger.error(TAG, `Failed to pause audio renderer. Cause${err.message}.`);
          return;
        }
        AppStorage.setOrCreate<AudioPlayerStatus>('audioPlayerStatus', AudioPlayerStatus.PAUSED);
        Logger.info(TAG, 'Succeeded to pause audio renderer. ');
      });
    }
  }

  public stopAudioRender() {
    if (this.renderer) {
      // The renderer can be stopped only when it is in the running or paused state.
      if (this.renderer.state.valueOf() !== audio.AudioState.STATE_RUNNING &&
        this.renderer.state.valueOf() !== audio.AudioState.STATE_PAUSED) {
        Logger.info(TAG, 'The renderer can be stopped only when it is in the running or paused state.');
        return;
      }
      // stop audio renderer
      this.renderer.stop((err: BusinessError) => {
        if (err) {
          Logger.error(TAG, `Failed to stop audio renderer. Cause${err.message}.`);
          return;
        }
        Logger.info(TAG, 'Succeeded to stop audio renderer. ');
      });
    }
  }

  public releaseAudioRender() {
    if (this.renderer) {
      // The render can be released only when it is not in the released state.
      if (this.renderer.state.valueOf() === audio.AudioState.STATE_RELEASED) {
        Logger.error(TAG, 'The render can be released only when it is not in the released state.');
        return;
      }
      // release audio renderer
      this.renderer.release((err: BusinessError) => {
        if (err) {
          Logger.error(TAG, `Failed to release audio renderer. Cause${err.message}.`);
          return;
        }

        AppStorage.delete('audioPlayerStatus');
        Logger.info(TAG, 'Succeeded to release audio renderer. ');
      });
    }
  }
}
