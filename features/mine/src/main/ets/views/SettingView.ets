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

import { ConfigurationConstant } from '@kit.AbilityKit';
import { BreakpointTypeEnum, CommonConstants, DarkModeSettingsConfig, DarkModeType, WindowUtil } from '@ohos/utils';
import { TopNavigationView } from '@ohos/uicomponents';
import { UserHeadComponent } from '../components/UserHeadComponent';

@Component
export struct SettingView {
  @Consume('appPathStack') appPathStack: NavPathStack;
  @Consume('settingPathStack') settingPathStack: NavPathStack;
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;
  @State selectedIndex: number = -1;
  changeStatusBar: boolean = false;

  goBack(): void {
    this.appPathStack.pop();
  }

  aboutToAppear() {
    if (this.currentBreakpoint === BreakpointTypeEnum.SM) {
      this.changeStatusBar = true;
      WindowUtil.updateStatusBarColor(getContext(this),
        AppStorage.get('currentColorMode') === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
    }
  }

  aboutToDisappear(): void {
    if (this.changeStatusBar) {
      WindowUtil.updateStatusBarColor(getContext(this), true);
    }
  }

  build() {
    NavDestination() {
      Navigation(this.settingPathStack) {
        Column() {
          TopNavigationView({
            title: $r('app.string.settings_title'),
            onBackClick: this.currentBreakpoint === BreakpointTypeEnum.SM ? () => this.goBack() : undefined
          })

          Column({ space: CommonConstants.SPACE_12 }) {
            UserAccountComponent({ selectedIndex: $selectedIndex })
            DarkModeSettingCard({ selectedIndex: $selectedIndex })
          }
          .padding(
            { left: $r('app.float.lg_padding_margin'), right: $r('app.float.lg_padding_margin') })
          .layoutWeight(1)
        }
        .height(CommonConstants.FULL_PERCENT)
        .width(CommonConstants.FULL_PERCENT)
        .padding({
          top: this.currentBreakpoint === BreakpointTypeEnum.SM ? AppStorage.get<number>('statusBarHeight') :
          $r('app.float.sm_padding_margin')
        })
      }
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
      .navBarWidth(CommonConstants.NAVI_BAR_WIDTH)
      .hideTitleBar(true)
      .title($r('app.string.settings_title'))
      .titleMode(NavigationTitleMode.Free)
      // .navDestination(this.pageMap)
    }
    .hideTitleBar(true)
  }
}

@Component
struct UserAccountComponent {
  @Consume('settingPathStack') settingPathStack: NavPathStack;
  @Link selectedIndex: number;
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;

  build() {
    Column() {
      Row() {
        UserHeadComponent()
          .layoutWeight(1)

        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontColor([$r('sys.color.ohos_id_color_text_tertiary')])
          .fontSize($r('app.float.nav_title_font_size'))
      }
      .backgroundColor(this.selectedIndex === 0 ? $r('app.color.setting_selected_bg') :
      $r('app.color.clear_color'))
      .width(CommonConstants.FULL_PERCENT)
      .borderRadius($r('app.float.large_border_radius'))
      .padding({
        left: $r('app.float.sm_padding_margin'),
        top: $r('app.float.lg_padding_margin'),
        right: $r('app.float.sm_padding_margin'),
        bottom: $r('app.float.lg_padding_margin')
      })
      .onClick(() => {
        this.settingPathStack.pushPathByName('UserAccountView', undefined);
      })
    }
    .backgroundColor($r('app.color.hmos_article_card_color_white'))
    .padding($r('app.float.ss_padding_margin'))
    .width(CommonConstants.FULL_PERCENT)
    .borderRadius($r('app.float.large_border_radius'))
  }
}

@Component
struct DarkModeSettingCard {
  @Consume('settingPathStack') settingPathStack: NavPathStack;
  @Link selectedIndex: number;
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;
  @StorageProp('darkModeConfig') darkModeConfig: DarkModeSettingsConfig = new DarkModeSettingsConfig();

  build() {
    Column() {
      Row() {
        Text($r('app.string.dark_mode_btn_title'))
          .fontFamily(CommonConstants.HARMONY_HEI_TI_FONT_FAMILY)
          .fontSize($r('app.float.default_font_size'))
          .fontWeight(CommonConstants.DIALOG_BUTTON_FONT_WEIGHT)
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .lineHeight($r('app.float.like_icon_width'))
          .layoutWeight(1)
        Text(this.darkModeConfig.switchType === DarkModeType.TIMED ? $r('app.string.dark_mode_timed') :
          (this.darkModeConfig.switchType === DarkModeType.ALL_DAY ? $r('app.string.dark_mode_all_day') :
          $r('app.string.dark_mode_follow_up')))
          .fontFamily(CommonConstants.HARMONY_HEI_TI_FONT_FAMILY)
          .fontSize($r('app.float.title_font_size'))
          .fontWeight(CommonConstants.NORMAL_FONT_WEIGHT)
          .lineHeight($r('app.float.view_area_height'))
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontColor([$r('sys.color.ohos_id_color_text_tertiary')])
          .fontSize($r('app.float.nav_title_font_size'))
      }
      .height($r('app.float.tab_bar_height'))
      .backgroundColor(this.selectedIndex === 1 ? $r('app.color.setting_selected_bg') :
      $r('app.color.clear_color'))
      .width(CommonConstants.FULL_PERCENT)
      .borderRadius($r('app.float.large_border_radius'))
      .padding({
        top: $r('app.float.md_padding_margin'),
        left: $r('app.float.sm_padding_margin'),
        bottom: $r('app.float.md_padding_margin'),
        right: $r('app.float.sm_padding_margin')
      })
    }
    .backgroundColor($r('app.color.hmos_article_card_color_white'))
    .width(CommonConstants.FULL_PERCENT)
    .borderRadius($r('app.float.large_border_radius'))
    .padding($r('app.float.ss_padding_margin'))
    .onClick(() => {
      this.settingPathStack.pushPathByName('ThemeConfigView', undefined);
    })
  }
}

@Builder
export function SettingViewBuilder(): void {
  SettingView();
}