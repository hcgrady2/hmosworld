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

import { AudioPlayerService, AudioPlayerStatus } from '@ohos/audioplayer';
import { CommonConstants } from '@ohos/utils';

enum IconStatue {
  NORMAL = 0,
  PLAYING,
  PAUSE,
  RESTART
}

@Component
export struct SpeakPlayerButton {
  @Prop speakText: string = '';
  @Watch('handleStatusChange') @StorageLink('audioPlayerStatus') audioPlayerStatus: AudioPlayerStatus =
    AudioPlayerStatus.IDLE;
  @State iconState: IconStatue = IconStatue.NORMAL;
  private audioPlayerService: AudioPlayerService = AudioPlayerService.getInstance();
  onInitSpeak?: () => void = () => {
  };

  handleStatusChange() {
    if (this.audioPlayerStatus === AudioPlayerStatus.PAUSED) {
      this.iconState = IconStatue.PAUSE;
    } else if (this.audioPlayerStatus === AudioPlayerStatus.IDLE) {
      this.iconState = IconStatue.NORMAL;
    } else if (this.audioPlayerStatus === AudioPlayerStatus.PLAYING) {
      if (this.iconState == IconStatue.PAUSE) {
        this.iconState = IconStatue.RESTART;
        setTimeout(() => {
          this.iconState = IconStatue.PLAYING;
        }, CommonConstants.SWIPER_DURATION);
      } else {
        this.iconState = IconStatue.PLAYING;
      }
    }
  }

  build() {
    Button({ type: ButtonType.Circle }) {
      if (this.audioPlayerStatus === AudioPlayerStatus.LOADING) {
        LoadingProgress()
          .color($r('sys.color.ohos_id_color_text_secondary_contrary'))
          .height($r('app.float.md_icon_size'))
      } else {
        Stack() {
          Image(this.iconState === IconStatue.PLAYING ? $r('app.media.ic_audio_playing') :
          $r('app.media.ic_audio_ear'))
            .height(this.iconState === IconStatue.PLAYING ? $r('app.float.audio_playing_size') :
            $r('app.float.audio_play_size'))
          Column() {
            Image(this.iconState === IconStatue.RESTART ? $r('app.media.ic_audio_pause') :
            $r('app.media.ic_audio_play'))
              .height($r('app.float.sm_icon_size'))
          }
          .justifyContent(FlexAlign.Center)
          .visibility((this.iconState === IconStatue.PLAYING || this.iconState === IconStatue.NORMAL) ?
          Visibility.Hidden : Visibility.Visible)
          .backgroundColor($r('app.color.btn_bg_color'))
          .width($r('app.float.lg_icon_size'))
          .borderRadius($r('app.float.icon_border_radius'))
          .aspectRatio(1)
        }
      }
    }
    .backgroundColor($r('app.color.btn_bg_color'))
    .backgroundBlurStyle(BlurStyle.Thin, { colorMode: ThemeColorMode.DARK, adaptiveColor: AdaptiveColor.AVERAGE })
    .width($r('app.float.lg_icon_size'))
    .height($r('app.float.lg_icon_size'))
    .onClick(() => {
      if (this.audioPlayerStatus === AudioPlayerStatus.IDLE) {
        this.onInitSpeak?.();
        this.audioPlayerService.speak(this.speakText);
      } else if (this.audioPlayerStatus === AudioPlayerStatus.PAUSED) {
        this.audioPlayerService.play();
      } else {
        this.audioPlayerService.pause();
      }
    })
  }
}