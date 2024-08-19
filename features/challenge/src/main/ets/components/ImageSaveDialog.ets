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

import { CommonConstants } from '@ohos/utils';

@CustomDialog
export struct ImageSaveDialog {
  share?: () => void;
  save?: () => void;
  controller: CustomDialogController;

  build() {
    Column() {
      Row() {
        Image($r('sys.media.ohos_ic_public_share'))
          .objectFit(ImageFit.Cover)
          .width($r('app.float.sm_img_size'))
          .height($r('app.float.sm_img_size'))
          .margin({ left: $r('app.float.icon_title_margin_bottom') })

        Text($r('app.string.save_image_button_share'))
          .fontSize($r('app.float.challenge_title_size_sm'))
          .margin({ left: $r('app.float.md_padding_margin') })
          .fontFamily(CommonConstants.HARMONY_HEITI_MEDIUM_FONT_FAMILY)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .opacity(CommonConstants.FIRST_LEVEL_OPACITY)
      }
      .height($r('app.float.save_btn_height'))
      .width(CommonConstants.FULL_PERCENT)

      Divider()
        .margin({ left: $r('app.float.divider_left_margin'), right: $r('app.float.md_padding_margin') })
        .color($r('sys.color.ohos_id_color_hover'))
        .strokeWidth(1)
      SaveButton({
        icon: SaveIconStyle.FULL_FILLED,
        text: SaveDescription.SAVE_TO_GALLERY,
        buttonType: ButtonType.Normal
      })
        .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
        .iconSize($r('app.float.sm_img_size'))
        .iconColor($r('sys.color.ohos_id_color_text_primary'))
        .textIconSpace($r('app.float.md_padding_margin'))
        .padding({ left: 0, right: 66 })
        .height($r('app.float.save_btn_height'))
        .width(CommonConstants.FULL_PERCENT)
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .onClick(async (event: ClickEvent, result: SaveButtonOnClickResult) => {
          if (result == SaveButtonOnClickResult.SUCCESS) {
            this.save?.();
          }
        })
    }
    .clip(true)
    .borderRadius($r('app.float.xl_border_radius'))
    .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
    .padding({
      top: $r('app.float.xs_padding_margin'),
      right: $r('app.float.xxl_padding_margin'),
      bottom: $r('app.float.xs_padding_margin'),
    })
    .width($r('app.float.save_dialog_width'))
    .height($r('app.float.save_image_dialog_height'))
  }
}