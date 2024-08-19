/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import { common } from '@kit.AbilityKit'
import { router } from '@kit.ArkUI';
import { UserAccount } from '@ohos/login';
import { BreakpointTypeEnum, CommonConstants, ContinueModel, EventTypeEnum, WindowUtil } from '@ohos/utils';
import Constants from '../constants/Constants';
import { LearningResource } from '../model/LearningResource';
import { TabInfo, UserModel } from '../model/UserModel';
import { AchievesView } from '../components/AchievesView';
import { ArticleDetailView } from './ArticleDetailView';
import { CollectedResourceView } from '../components/CollectedResourcesView';
import { ViewedResourceView } from '../components/ViewedResourceView';
import { SettingView } from './SettingView';

let continueModel = ContinueModel.getInstance();
const eventHub: common.EventHub = (getContext() as common.UIAbilityContext).eventHub;

/**
 * Pull to reload offset const value
 */
const RELOAD_ANIMATION_DELAY = 1500;

@Component
export struct MineView {
  @State userModel: UserModel = UserModel.getInstance();
  @State currentIndex: TabInfo = TabInfo.COLLECTED;
  /**
   * Whether to trigger a refresh, the value is controlled by the scroll example;
   */
  @State isRefresh: boolean = false;
  /**
   * Y-axis drag distance;
   */
  @State offsetY: number = 0;
  /**
   * Control the disappear and appear of user image;
   */
  private outScroller: Scroller = new Scroller();
  private innerScroller: Scroller = new Scroller();
  /**
   * User timer to limit the request count of reload;
   */
  private timer: number = 0;
  @Consume('minePathStack') minePathStack: NavPathStack;
  @State isShowSmallImg: boolean = false;
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;

  @Builder
  MineTabs(index: number, barName: Resource) {
    Column() {
      Text(barName)
        .fontColor(index === this.currentIndex ? $r('sys.color.ohos_id_color_subtab_text_on') :
        $r('sys.color.ohos_id_color_text_secondary'))
        .fontWeight(index === this.currentIndex ? FontWeight.Medium : FontWeight.Normal)
        .fontSize($r('app.float.default_font_size'))
        .margin({ top: $r('app.float.sm_padding_margin'), bottom: $r('app.float.mine_tab_margin') })
      Divider()
        .strokeWidth(2)
        .lineCap(LineCapStyle.Round)
        .width($r('app.float.divider_width_32'))
        .color(index === this.currentIndex ? $r('sys.color.ohos_id_color_subtab_text_on') :
        $r('app.color.hmos_color_white'))
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.hmos_color_white'))
  }

  @Builder
  MineBackGroundImage() {
    // background Image
    Column() {
      Image($r('app.media.user_background_image'))
        .width(CommonConstants.FULL_PERCENT)
        .height(this.calImageHeight())
        .objectFit(ImageFit.Cover)
    }
    .width(CommonConstants.FULL_PERCENT)
    .aspectRatio(3 / 2)
  }

  @Builder
  MineRefresh() {
    LoadingProgress()
      .size({
        width: $r('app.float.login_size'),
        height: $r('app.float.login_size')
      })
      .width(CommonConstants.FULL_PERCENT)
      .color(Color.White)
  }

  aboutToAppear(): void {
    WindowUtil.updateStatusBarColor(getContext(this), true);
    if (continueModel.isContinue) {
      this.currentIndex = continueModel.data.mineTabIndex;
    }
  }

  calImageHeight(): number {
    return (this.offsetY + 150) * 2.5;
  }

  @Builder
  mineRouter(name: string, param: LearningResource) {
    if (name === 'detailLarge') {
      ArticleDetailView({
        articleDetail: param,
        isLarge: true
      })
    }
  }

  onDestinationBack(): boolean {
    this.minePathStack.pop();
    return true;
  }

  build() {
    Navigation(this.minePathStack) {
      Stack({ alignContent: Alignment.Top }) {
        // BackgroundImage view;
        if (this.currentBreakpoint !== BreakpointTypeEnum.LG) {
          this.MineBackGroundImage()
        }

        Column() {
          // Header include user small image and setting;
          MineHeader({ isShowSmallImg: this.isShowSmallImg })

          Refresh({ refreshing: $$this.isRefresh, builder: this.MineRefresh() }) {
            List({ scroller: this.outScroller }) {
              // user image and information;
              ListItem() {
                UserInfoView()
              }
              .onVisibleAreaChange([0, 1], (isVisible: boolean, currentRatio: number) => {
                if (currentRatio == 0 && !isVisible && this.outScroller.currentOffset().yOffset !== 0) {
                  this.isShowSmallImg = true;
                } else if (currentRatio == 1 && isVisible) {
                  this.isShowSmallImg = false;
                }
              })

              // Tabs for user collected 、viewed resource and achievements;
              ListItem() {
                Tabs({ index: this.currentIndex }) {
                  TabContent() {
                    CollectedResourceView({ innerScroller: this.innerScroller, outerScroller: this.outScroller })
                  }
                  .padding({ top: $r('app.float.md_padding_margin') })
                  .tabBar(this.MineTabs(TabInfo.COLLECTED, $r('app.string.my_collected')))
                  .backgroundColor($r('app.color.hmos_background_color_white'))

                  TabContent() {
                    ViewedResourceView({ innerScroller: this.innerScroller, outerScroller: this.outScroller })
                  }
                  .tabBar(this.MineTabs(TabInfo.VIEWED, $r('app.string.my_viewed')))
                  .backgroundColor($r('app.color.hmos_background_color_white'))
                  .padding({ top: $r('app.float.md_padding_margin') })

                  TabContent() {
                    AchievesView()
                  }
                  .tabBar(this.MineTabs(TabInfo.ACHIEVEMENT, $r('app.string.my_achieve')))
                  .backgroundColor($r('app.color.hmos_background_color_white'))
                  .padding({ top: $r('app.float.md_padding_margin') })
                }
                .backgroundColor($r('app.color.hmos_color_white'))
                .borderRadius($r('app.float.tabs_border_radius'))
                .vertical(false)
                .barMode(BarMode.Fixed)
                .barWidth($r('app.float.tab_bar_width'))
                .barHeight($r('app.float.tab_bar_height'))
                .layoutWeight(1)
                .onChange((index: number) => {
                  this.currentIndex = index;
                  continueModel.data.mineTabIndex = index;
                })
              }
            }
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.None)
            .width(CommonConstants.FULL_PERCENT)
            .height(CommonConstants.FULL_PERCENT)
            .layoutWeight(1)
          }
          .onRefreshing(() => {
            this.timer = setTimeout(() => {
              this.userModel.reload(this.currentIndex).then(() => {
                if (this.currentBreakpoint === BreakpointTypeEnum.LG) {
                  eventHub.emit(EventTypeEnum.MINE_REFRESH);
                }
              });
              this.isRefresh = false;
              clearTimeout(this.timer);
            }, RELOAD_ANIMATION_DELAY);
          })
          .onOffsetChange((value: number) => {
            this.offsetY = value;
          })
        }
        .height(CommonConstants.FULL_PERCENT)
      }
    }
    .hideTitleBar(true)
    .navDestination(this.mineRouter)
    .mode(NavigationMode.Stack)
  }
}

@Component
struct MineHeader {
  @Consume('appPathStack') appPathStack: NavPathStack;
  userModel: UserModel = UserModel.getInstance();
  @Prop isShowSmallImg: boolean = false;
  @State showSettingModal: boolean = false;
  @StorageProp('isLogged') isLogged: boolean = false;
  @StorageProp('user') account: UserAccount | null = null;
  @StorageProp('profilePixelMap') profilePixelMap: PixelMap | null = null;
  @StorageProp('foldExpanded') @Watch('foldExpandChange') foldExpanded: boolean = false;
  @StorageProp('currentBreakpoint') @Watch('foldExpandChange') currentBreakpoint: string = BreakpointTypeEnum.MD;

  foldExpandChange() {
    if (this.foldExpanded && this.currentBreakpoint === BreakpointTypeEnum.MD &&
      this.appPathStack.getIndexByName('SettingView').length > 0) {
      this.showSettingModal = true;
      this.appPathStack.pop();
    } else if (!this.foldExpanded && this.currentBreakpoint === BreakpointTypeEnum.SM && this.showSettingModal) {
      this.appPathStack.pushPathByName('SettingView', undefined);
      this.showSettingModal = false;
    }
  }

  @Builder
  settingModal() {
    Column() {
      SettingView()
    }
    .width($r('app.float.setting_modal_width'))
    .height($r('app.float.setting_modal_height'))
  }

  build() {
    Row() {
      Blank()
      Image($r('app.media.ic_topic'))
        .width($r('app.float.topic_image_size'))
        .aspectRatio(1)
        .margin({ right: $r('app.float.topic_margin_right') })
        .onClick(() => {
          router.pushNamedRoute({ name: 'ThemeSettingPage' });
        })

      Image($r('app.media.ic_public_settings_white'))
        .width($r('app.float.normal_icon_size'))
        .height($r('app.float.normal_icon_size'))
        .margin({ right: $r('app.float.topic_margin_right') })
        .onClick(() => {
          if (this.currentBreakpoint === BreakpointTypeEnum.SM) {
            this.appPathStack.pushPathByName('SettingView', undefined);
          } else {
            this.showSettingModal = true;
          }
        })
        .bindSheet($$this.showSettingModal, this.settingModal(), {
          preferType: SheetType.CENTER,
          dragBar: false,
          maskColor: $r('sys.color.ohos_id_color_fourth'),
          backgroundColor: $r('sys.color.ohos_id_color_panel_bg'),
        })

      Image(this.profilePixelMap != null ? AppStorage.get<PixelMap>('profilePixelMap')
        : (this.isLogged ? this.account?.portrait : $r('app.media.user_default')))
        .size({
          width: $r('app.float.account_image_size'),
          height: $r('app.float.account_image_size')
        })
        .position({
          x: Constants.ACCOUNT_POSITION_X,
          y: this.isShowSmallImg ? $r('app.float.regular_margin') : $r('app.float.header_height')
        })
        .borderRadius($r('app.float.user_portrait_border_radius'))
        .opacity(this.isShowSmallImg ? 1 : 0)
        .animation({ duration: Constants.SHORT_ANIMATION_DURATION })
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .margin({ top: AppStorage.get<number>('statusBarHeight') })
    .height($r('app.float.header_height'))
    .width(CommonConstants.FULL_PERCENT)
  }
}

@Component
struct UserInfoView {
  @Consume('appPathStack') appPathStack: NavPathStack;
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;
  @StorageProp('isLogged') isLogged: boolean = false;
  @StorageProp('user') account: UserAccount | null = null;
  @StorageProp('profilePixelMap') profilePixelMap: PixelMap | null = null;

  build() {
    Column() {
      Row({ space: Constants.MIDDLE_SPACE }) {
        Image(this.profilePixelMap != null ? AppStorage.get<PixelMap>('profilePixelMap')
          : (this.isLogged ? this.account?.portrait : $r('app.media.user_default')))
          .size({ width: $r('app.float.user_image_size'), height: $r('app.float.user_image_size') })
          .borderRadius($r('app.float.xxl_border_radius'))
          .margin({ bottom: $r('app.float.lg_padding_margin'), top: $r('app.float.lg_padding_margin') })
          .onClick(() => {
            this.appPathStack.pushPathByName('PhotoView', undefined);
          })

        Text(this.isLogged ? this.account?.nickname : $r('app.string.default_login'))
          .fontColor($r('app.color.hmos_font_color_white'))
          .fontSize($r('app.float.user_account_font_size'))
          .padding({ bottom: $r('app.float.login_account_padding_bottom') })
          .onClick(() => {
            if (!this.isLogged) {
              router.pushNamedRoute({ name: 'LoginPage' });
            }
          })
      }
      .width(CommonConstants.FULL_PERCENT)
      .justifyContent(this.isLogged ? FlexAlign.Start : FlexAlign.Center)

      Text(this.isLogged ? this.account?.description : $r('app.string.default_description'))
        .width(CommonConstants.FULL_PERCENT)
        .fontSize($r('app.float.title_font_size'))
        .fontColor($r('app.color.hmos_font_color_white'))
    }
    .alignItems(HorizontalAlign.Start)
    .padding({ left: $r('app.float.xxl_padding_margin') })
    .width(CommonConstants.FULL_PERCENT)
    .height(this.currentBreakpoint === BreakpointTypeEnum.LG ? $r('app.float.user_background_height_md') :
    $r('app.float.user_background_height_lg'))
  }
}