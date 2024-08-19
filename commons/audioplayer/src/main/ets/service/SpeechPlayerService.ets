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

import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo, WriteOptions } from '@kit.CoreFileKit';
import { textToSpeech } from '@kit.CoreSpeechKit';
import { Logger } from '@ohos/utils';

const TAG = '[SpeechPlayerService]';
export const TEMP_AUDIO_FILE_NAME = '/temp.pcm';

export class SpeechPlayerService {
  private bufferSize: number = 0;
  private ttsEngine: textToSpeech.TextToSpeechEngine | undefined = undefined;
  private static instance: SpeechPlayerService;

  public static getInstance(): SpeechPlayerService {
    if (!SpeechPlayerService.instance) {
      SpeechPlayerService.instance = new SpeechPlayerService();
    }
    return SpeechPlayerService.instance;
  }

  // init TextToSpeechEngine
  public createTextToSpeechEngine(): Promise<void> {
    const extraParam: Record<string, Object> =
      { "style": 'interaction-broadcast', "locate": 'CN', "name": 'EngineName' };
    const initParamsInfo: textToSpeech.CreateEngineParams = {
      language: 'zh-CN',
      person: 0,
      online: 1,
      extraParams: extraParam
    };
    return textToSpeech.createEngine(initParamsInfo).then(textToSpeechEngine => {
      this.ttsEngine = textToSpeechEngine;
      this.setListener();
      Logger.info(TAG, 'Succeeded to create textToSpeechEngine.');
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `Failed to create textToSpeechEngine.Cause: ${err.message}`);
    })
  }

  // set speak listener
  public setListener() {
    let speakListener: textToSpeech.SpeakListener = {
      onStart: (requestId: string, response: textToSpeech.StartResponse) => {
        Logger.info(TAG, 'speakListener onStart.');
      },
      onComplete: (requestId: string, response: textToSpeech.CompleteResponse) => {
        this.bufferSize = 0;
        Logger.info(TAG, 'speakListener onComplete.');
      },
      onStop: (requestId: string, response: textToSpeech.StopResponse) => {
        this.bufferSize = 0;
        Logger.info(TAG, 'speakListener onStop.');
      },
      onData: (requestId: string, audio: ArrayBuffer, response: textToSpeech.SynthesisResponse) => {
        let path = getContext().tempDir;
        let filePath = path + TEMP_AUDIO_FILE_NAME;
        let file: fileIo.File = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
        let options: WriteOptions = {
          offset: this.bufferSize,
          length: audio.byteLength
        };
        fileIo.writeSync(file.fd, audio, options);
        this.bufferSize += audio.byteLength;
      },
      onError: (requestId: string, errorCode: number, errorMessage: string) => {
        Logger.error(TAG, `speakListener onError:  ${errorMessage}`);
      }
    };
    this.ttsEngine?.setListener(speakListener);
  }

  // speak text
  async speak(text: string) {
    if (this.ttsEngine) {
      let extraParam: Record<string, Object> = {
        "queueMode": 0,
        "speed": 1,
        "volume": 2,
        "pitch": 1,
        "languageContext": 'zh-CN',
        "audioType": "pcm",
        "soundChannel": 1,
        "playType": 0
      }
      let speakParams: textToSpeech.SpeakParams = {
        requestId: util.generateRandomUUID(),
        extraParams: extraParam
      };
      this.ttsEngine.speak(text, speakParams);
    }
  };

  // stop TextToSpeechEngine
  async stopTextToSpeechEngine() {
    try {
      this.ttsEngine?.stop();
      Logger.info(TAG, 'Succeeded to stop textToSpeechEngine.');
    } catch (error) {
      Logger.error(TAG, `Failed to stop textToSpeechEngine.Cause: ${(error as BusinessError).message}`);
    }
  }

  // release TextToSpeechEngine
  public releaseTextToSpeechEngine() {
    try {
      this.ttsEngine?.shutdown();
      Logger.info(TAG, 'Succeeded to release textToSpeechEngine.');
    } catch (error) {
      Logger.error(TAG, `Failed to release textToSpeechEngine.Cause: ${(error as BusinessError).message}`);
    }
  }
}