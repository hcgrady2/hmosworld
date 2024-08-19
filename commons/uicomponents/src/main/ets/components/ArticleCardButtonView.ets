/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { CommonConstants, CommonUtil, LottieUtil } from '@ohos/utils';
import { Constants } from '../common/Constants';

@Component
export struct ArticleCardButtonView {
  @Prop isClicked: boolean = false;
  @Prop count: number = 0;
  @Prop textWidth: Resource = $r('app.float.default_icon_width');
  @Prop articleId: string = '';
  @Prop clickAnimationPath: string = '';
  @Prop cancelAnimationPath: string = '';
  @Prop type: string = '';
  @Prop normalImage: Resource = $r('app.media.ic_failure');
  @Prop onImage: Resource = $r('app.media.ic_failure');
  @State playingAnimation: boolean = false;
  onClicked?: () => void;
  private mainRenderingSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private mainCanvasRenderingContext: CanvasRenderingContext2D =
    new CanvasRenderingContext2D(this.mainRenderingSettings);

  startLottieAnimation() {
    const animationItem = LottieUtil.loadAnimation({
      container: this.mainCanvasRenderingContext,
      renderer: 'canvas',
      loop: false,
      autoplay: false,
      name: this.articleId + this.type,
      path: this.isClicked ? this.cancelAnimationPath : this.clickAnimationPath
    });
    animationItem.addEventListener('complete', () => {
      this.playingAnimation = false;
      LottieUtil.destroy(this.articleId + this.type);
    });
    animationItem.addEventListener('error', () => {
      this.playingAnimation = false;
      LottieUtil.destroy(this.articleId + this.type);
    });
    LottieUtil.play(this.articleId + this.type);

    this.isClicked = !this.isClicked;
    this.onClicked?.();
  }

  build() {
    Row() {
      Stack() {
        if (!this.playingAnimation) {
          Image(this.isClicked ? this.onImage : this.normalImage)
            .margin({ right: $r('app.float.xs_padding_margin') })
            .size({ width: $r('app.float.default_icon_width'), height: $r('app.float.default_icon_width') })
        } else {
          Canvas(this.mainCanvasRenderingContext)
            .size({ width: $r('app.float.default_icon_width'), height: $r('app.float.default_icon_width') })
            .margin({ right: $r('app.float.xs_padding_margin') })
            .id('canvas' + this.articleId + this.type)
            .onReady(() => {
              this.startLottieAnimation();
            })
        }
      }

      // SymbolGlyph($r('sys.symbol.hand_thumbsup_fill'))
      //   // .symbolEffect()
      //   .fontSize(16)
      Text(CommonUtil.transNumberOverOneThousand(this.count))
        .fontFamily(CommonConstants.HARMONY_HEI_TI_FONT_FAMILY)
        .fontSize($r('app.float.small_text_size'))
        .width(this.textWidth)
        .opacity(Constants.SECOND_LEVEL_OPACITY)
    }
    .onClick(() => {
      this.playingAnimation = true;
    })
    .width($r('app.float.action_button_width'))
    .padding({ top: $r('app.float.sm_padding_margin'), bottom: $r('app.float.sm_padding_margin') })
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}