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

import { UserAccount } from '@ohos/login';
import { CommonConstants } from '@ohos/utils';

@Component
export struct UserHeadComponent {
  @StorageProp('isLogged') isLogged: boolean = false;
  @StorageProp('user') account: UserAccount | null = null;
  @StorageProp('profilePixelMap') profilePixelMap: PixelMap | null = null;

  build() {
    Row() {
      Image(this.profilePixelMap != null ? AppStorage.get<PixelMap>('profilePixelMap')
        : (this.isLogged ? this.account?.portrait : $r('app.media.user_default')))
        .width($r('app.float.button_height'))
        .height($r('app.float.button_height'))
        .margin({ right: $r('app.float.md_padding_margin') })

      Column() {
        Text(this.isLogged ? this.account?.nickname : $r('app.string.login_btn_default_title'))
          .fontFamily(CommonConstants.HARMONY_HEI_TI_FONT_FAMILY)
          .fontSize($r('app.float.default_font_size'))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(CommonConstants.DIALOG_BUTTON_FONT_WEIGHT)
          .lineHeight($r('app.float.like_icon_width'))
        Text(this.isLogged ? this.account?.description : $r('app.string.login_btn_default_descriptions'))
          .fontFamily(CommonConstants.HARMONY_HEI_TI_FONT_FAMILY)
          .fontSize($r('app.float.title_font_size'))
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .fontWeight(CommonConstants.NORMAL_FONT_WEIGHT)
          .lineHeight($r('app.float.view_area_height'))
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
  }
}