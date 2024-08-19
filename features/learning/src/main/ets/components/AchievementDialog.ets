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

import { BreakpointType, BreakpointTypeEnum } from '@ohos/utils';
import { LearningConstants } from '../constants/LearningConstants';
import { LearningPath } from '../model/LearningPath';

@Component
@CustomDialog
export struct AchievementDialog {
  controller?: CustomDialogController;
  @Link learningItem: LearningPath | null;
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;

  closeDialog(): void {
    this.controller?.close();
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_close'))
          .objectFit(ImageFit.Contain)
          .height($r('app.float.achieve_close_icon_size'))
          .width($r('app.float.achieve_close_icon_size'))
          .onClick(() => this.closeDialog())
      }
      .padding({
        top: $r('app.float.achieve_close_icon_margin_top'),
        bottom: $r('app.float.achieve_close_icon_margin_top')
      })
      .justifyContent(FlexAlign.End)
      .width(LearningConstants.FULL_PERCENT)

      Column() {
        Image(this.learningItem?.achieveImg)
          .margin({ top: $r('app.float.achieve_margin_top') })
          .zIndex(LearningConstants.ACHIEVEMENT_Z_INDEX)
          .width($r('app.float.achieve_img_size'))
          .aspectRatio(LearningConstants.ACHIEVEMENT_ASPECT_RATIO)
        Column() {
          Text($r('app.string.welcome_to_unlock', this.learningItem?.title))
            .fontSize($r('app.float.font_size_large'))
            .lineHeight($r('app.float.achieve_title_line_height'))
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.Black)
            .textAlign(TextAlign.Center)
          Text($r('app.string.look_achieve_to_mine'))
            .margin({ top: $r('app.float.achieve_text_margin_top') })
            .fontSize($r('app.float.font_size_normal'))
            .fontColor($r('app.color.achieve_grey_text_color'))
        }
        .width(LearningConstants.FULL_PERCENT)
        .padding($r('app.float.navigation_margin'))
        .layoutWeight(1)

        Row() {
          Text($r('app.string.btn_ok'))
            .fontColor($r('app.color.white'))
            .fontSize($r('app.float.btn_font_size'))
        }
        .width($r('app.float.achieve_btn_width'))
        .height($r('app.float.achieve_btn_height'))
        .backgroundImage($r('app.media.bg_button'))
        .backgroundImageSize(ImageSize.Contain)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: $r('app.float.achieve_btn_margin_top') })
        .onClick(() => this.closeDialog())
      }
      .backgroundColor(Color.White)
      .borderRadius($r('app.float.common_border_radius'))
      .layoutWeight(1)
    }
    .height($r('app.float.dialog_height'))
    .width(new BreakpointType({
      sm: $r('app.float.sm_dialog_width'),
      md: $r('app.float.md_dialog_width'),
      lg: $r('app.float.lg_dialog_width')
    }).getValue(this.currentBreakpoint))
    .justifyContent(FlexAlign.Center)
  }
}