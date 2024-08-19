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

import { common, wantAgent } from '@kit.AbilityKit';
import { avSession } from '@kit.AVSessionKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { BackgroundTaskManager, Logger } from '@ohos/utils';
import { AudioRenderService } from './AudioRenderService';
import { SpeechPlayerService } from './SpeechPlayerService';

const TAG = '[AVSessionService]';
const TEXT_TO_AUDIO_LOADING_TIME = 1000;

export enum AudioPlayerStatus {
  LOADING = 'loading',
  IDLE = 'idle',
  PLAYING = 'playing',
  PAUSED = 'paused',
}

export class AudioPlayerService {
  private context: common.UIAbilityContext | undefined = AppStorage.get('uiAbilityContext');
  private speechPlayerService: SpeechPlayerService = SpeechPlayerService.getInstance();
  private audioRenderService: AudioRenderService = AudioRenderService.getInstance();
  private session: avSession.AVSession | undefined = undefined;
  private static instance: AudioPlayerService | null;

  constructor() {
    this.initAudioPlayerService();
  }

  public static getInstance(): AudioPlayerService {
    if (!AudioPlayerService.instance) {
      AudioPlayerService.instance = new AudioPlayerService();
    }
    return AudioPlayerService.instance;
  }

  setSessionPlayState(state: avSession.PlaybackState) {
    this.session?.setAVPlaybackState({ state });
  }

  private async initAudioPlayerService() {
    await this.speechPlayerService.createTextToSpeechEngine().then(() => {
      if (this.context) {
        this.audioRenderService.initAudioRenderInit();
        this.createSession();
        BackgroundTaskManager.startContinuousTask(this.context);
        AppStorage.setOrCreate<AudioPlayerStatus>('audioPlayerStatus', AudioPlayerStatus.IDLE);
      }
    })
  }

  public async speak(text: string) {
    AppStorage.setOrCreate('audioPlayerStatus', AudioPlayerStatus.LOADING);
    await this.speechPlayerService.speak(text);
    // Ensure that the text is read after being converted to the audio stream to prevent the audio file from having no data.
    setTimeout(() => {
      this.setAVMetadata();
      this.play();
    }, TEXT_TO_AUDIO_LOADING_TIME);
  }

  public async play() {
    this.audioRenderService.startAudioRender();
  }

  public async pause() {
    this.audioRenderService.pauseAudioRender();
  }

  public async stop() {
    await this.speechPlayerService.stopTextToSpeechEngine();
    this.audioRenderService.stopAudioRender();
  }

  public async setAVMetadata() {
    const avMetadata: avSession.AVMetadata | undefined = AppStorage.get('avMetadata');
    if (this.context && avMetadata) {
      this.session?.setAVMetadata(avMetadata).then(() => {
        Logger.info(TAG, 'Set AVMetadata successfully.');
      }).catch((err: BusinessError) => {
        Logger.info(TAG, `Set AVMetadata failed. Cause: ${err.message}.`);
      });
    }
  }

  public createSession() {
    avSession.createAVSession(this.context, 'SPEECH_AUDIO_SESSION', 'audio').then(async (avSession) => {
      this.session = avSession;
      Logger.info(TAG, 'Succeeded in create avSession.');
      await this.setAVMetadata();
      const wantAgentInfo: wantAgent.WantAgentInfo = {
        wants: [
          {
            bundleName: this.context?.abilityInfo.bundleName,
            abilityName: this.context?.abilityInfo.name
          }
        ],
        operationType: wantAgent.OperationType.START_ABILITIES,
        requestCode: 0,
        wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
      }
      wantAgent.getWantAgent(wantAgentInfo).then((agent) => {
        this.session?.setLaunchAbility(agent);
      })
      this.setListenerForMesFromController();
      this.session.activate();
    });
  }

  public setListenerForMesFromController() {
    this.session?.on('play', () => {
      this.play();
    });
    this.session?.on('pause', () => {
      this.pause();
    });
  }

  public unregisterSessionListener() {
    this.session?.off('play');
    this.session?.off('pause');
  }

  public releaseAudioPlayer() {
    this.speechPlayerService.releaseTextToSpeechEngine();
    this.audioRenderService.releaseAudioRender();
    if (this.context && this.session) {
      BackgroundTaskManager.stopContinuousTask(this.context);
      this.unregisterSessionListener();
      this.session.destroy();
      this.session = undefined;
    }
  }

  public static destroy() {
    AudioPlayerService.getInstance().releaseAudioPlayer();
    AudioPlayerService.instance = null;
  }
}