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

import { router } from '@kit.ArkUI';
import { TopNavigationView } from '@ohos/uicomponents';
import { BreakpointTypeEnum, CommonConstants } from '@ohos/utils';
import { UserHeadComponent } from '../components/UserHeadComponent';
import { UserModel } from '../model/UserModel';

import('@ohos/login/src/main/ets/pages/LoginPage');

@Component
export struct UserAccountView {
  @State userModel: UserModel = UserModel.getInstance();
  @Consume('settingPathStack') settingPathStack: NavPathStack;
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;

  onBackPress(): boolean | void {
    this.settingPathStack.pop();
  }

  build() {
    NavDestination() {
      Column() {
        TopNavigationView({
          title: $r('app.string.hmos_account'),
          onBackClick: this.currentBreakpoint === BreakpointTypeEnum.SM ? () => this.onBackPress() : undefined
        })
        Column({ space: CommonConstants.SPACE_12 }) {
          Row() {
            UserHeadComponent()
          }
          .width(CommonConstants.FULL_PERCENT)
          .padding({
            left: $r('app.float.md_padding_margin'),
            top: $r('app.float.xl_padding_margin'),
            right: $r('app.float.md_padding_margin'),
            bottom: $r('app.float.xl_padding_margin')
          })

          Row() {
            Image($r('app.media.ic_personal'))
              .width($r('app.float.icon_size_sm'))
              .fillColor($r('sys.color.ohos_id_color_secondary'))
            Text($r('app.string.personal_info'))
              .fontFamily(CommonConstants.HARMONY_HEI_TI_FONT_FAMILY)
              .fontSize($r('app.float.default_font_size'))
              .fontWeight(CommonConstants.DIALOG_BUTTON_FONT_WEIGHT)
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .lineHeight($r('app.float.like_icon_width'))
              .margin({ left: $r('app.float.xl_padding_margin') })
              .layoutWeight(1)
            SymbolGlyph($r('sys.symbol.chevron_right'))
              .fontColor([$r('sys.color.ohos_id_color_text_tertiary')])
              .fontSize($r('app.float.nav_title_font_size'))
          }
          .backgroundColor($r('app.color.hmos_article_card_color_white'))
          .width(CommonConstants.FULL_PERCENT)
          .padding({
            left: $r('app.float.md_padding_margin'),
            top: $r('app.float.lg_padding_margin'),
            right: $r('app.float.md_padding_margin'),
            bottom: $r('app.float.lg_padding_margin')
          })
          .borderRadius($r('app.float.large_border_radius'))

          Blank()
          Button($r('app.string.logout'))
            .onClick(() => {
              this.userModel.deleteUserAccount().then(()=>{
                router.replaceNamedRoute({
                  name: 'LoginPage'
                });
              });
            })
            .fontColor($r('sys.color.ohos_id_color_badge_red'))
            .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
            .width(CommonConstants.FULL_PERCENT)
            .height($r('app.float.button_height'))
            .margin({ bottom: $r('app.float.sm_padding_margin') })
        }
        .padding(this.currentBreakpoint === BreakpointTypeEnum.LG ?
          { left: $r('app.float.xxl_padding_margin'), right: $r('app.float.xxl_padding_margin') } :
          { left: $r('app.float.lg_padding_margin'), right: $r('app.float.lg_padding_margin') })
        .layoutWeight(1)
      }
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
      .padding({
        top: this.currentBreakpoint === BreakpointTypeEnum.SM ? AppStorage.get<number>('statusBarHeight') :
        $r('app.float.sm_padding_margin'),
        bottom: AppStorage.get<number>('naviIndicatorHeight')
      })
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .hideTitleBar(true)
  }
}

@Builder
export function UserAccountViewBuilder(): void {
  UserAccountView();
}