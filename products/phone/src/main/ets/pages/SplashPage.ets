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

import { router } from '@kit.ArkUI';
import { common, ConfigurationConstant } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { PreferenceManager } from '@ohos/datastore';
import { DiscoverModel } from '@ohos/discover';
import {
  BreakpointSystem,
  BreakpointType,
  BreakpointTypeEnum,
  CommonConstants,
  DarkModeUtil,
  Logger,
  WindowUtil
} from '@ohos/utils';
import { TopicModel } from '@ohos/topic';
import { UserModel } from '@ohos/mine';
import { BgInfo, SplashConstants } from '../constants/SplashConstants';
import { SplashSource } from '../model/SplashSource';
import { SplashImages } from '../model/SplashModel';

const TAG: string = '[SplashPage]';

@Entry
@Component
struct SplashPage {
  private preferenceManager: PreferenceManager = PreferenceManager.getInstance();
  isAgreedPrivacy: boolean =
    router.getParams() ? (router.getParams() as Record<string, boolean>)['isAgreedPrivacy'] : false;
  @State showSwiper: boolean = false;
  @State firstStart: boolean = true;
  loggedIn: boolean = false;
  private data: SplashSource = new SplashSource();
  private swiperController: SwiperController = new SwiperController();
  private userModel: UserModel = UserModel.getInstance();
  private topicModel: TopicModel = TopicModel.getInstance();
  private discoverModel: DiscoverModel = DiscoverModel.getInstance();
  private current_swiper: BgInfo = {
    time: 'day',
    index: 0
  };
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;
  private breakpointSystem: BreakpointSystem = new BreakpointSystem();

  aboutToDisappear() {
    Logger.info(TAG, 'aboutToDisappear');
    this.breakpointSystem.unregister();
  }

  onPageShow() {
    WindowUtil.updateStatusBarColor(getContext(this), true);
  }

  onPageHide() {
    Logger.info(TAG, 'onPageHide');
    WindowUtil.updateStatusBarColor(getContext(this),
      AppStorage.get('currentColorMode') === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
  }

  aboutToAppear(): void {
    DarkModeUtil.getInstance().checkDarkModeSetting();
    this.dynamicLoading();
    setTimeout(() => {
      this.checkAgreedPrivacy();
    }, 0);

    this.breakpointSystem.register();
    let data: Resource[] = [];
    let hours = new Date().getHours();
    if (hours >= SplashConstants.MORNING_TIME && hours < SplashConstants.EVENING_TIME) {
      data = SplashImages.day;
      this.current_swiper.time = 'day';
    } else if (hours >= SplashConstants.EVENING_TIME && hours <= SplashConstants.NIGHT_TIME) {
      data = SplashImages.dusk;
      this.current_swiper.time = 'dusk';
    } else {
      data = SplashImages.night;
      this.current_swiper.time = 'night';
    }
    this.data.setDataArray(data);
  }

  dynamicLoading(): void {
    try {
      import('@ohos/login/src/main/ets/pages/LoginPage');
      import('@ohos/topic/src/main/ets/pages/ThemeSettingPage');
    } catch (err) {
      Logger.error(TAG, 'dynamicLoading error:' + err);
    }
  }

  init(): void {
    this.LoadingResource();
    this.checkIsFirstStart();

    setTimeout(() => {
      if (this.firstStart) {
        this.showSwiper = true;
      } else {
        this.jump();
      }
    }, SplashConstants.LOADING_RESOURCE_DURATION);
  }

  checkAgreedPrivacy(): void {
    if (this.isAgreedPrivacy) {
      this.preferenceManager.setValue('isAgreedPrivacy', true).then(() => {
        Logger.info(TAG, 'Put the value of isAgreedPrivacy Successfully.');
        this.init();
      }).catch((err: BusinessError) => {
        Logger.error(TAG, 'Put the value of isAgreedPrivacy Failed, err: ' + err);
      });
    } else {
      this.preferenceManager.getValue<boolean>('isAgreedPrivacy').then((isAgreed: boolean | null) => {
        if (isAgreed) {
          this.init();
        } else {
          router.replaceUrl({ url: 'pages/SafePage' });
        }
      }).catch((err: BusinessError) => {
        Logger.error(TAG, 'check isAgreedPrivacy Failed, err: ' + err);
      });
    }
  }

  LoadingResource(): void {
    // Wait 1s for dependent resource initialization to complete
    this.userModel.checkIsLogged().then((logged: boolean) => {
      AppStorage.setOrCreate('getHomeResource', true);
      if (logged) {
        this.loggedIn = true;
        this.userModel.getUserData();
        this.discoverModel.getHomeResources();
        this.topicModel.getTopics();
      }
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `LoadingResource getUserAccount failed: ${err}`);
      AppStorage.setOrCreate('getHomeResource', true);
    });
  }

  jump(): void {
    let bundleName = (getContext(this) as common.UIAbilityContext).applicationInfo.name;
    if (!this.loggedIn) {
      router.replaceNamedRoute({
        name: 'LoginPage',
        params: {
          bgImg: this.data.getData(this.current_swiper.index)
        }
      });
      return;
    }
    this.preferenceManager.getValue<boolean>('ThemeIsSet').then((isSet: boolean | null) => {
      if (isSet) {
        router.replaceUrl({
          url: `@bundle:${bundleName}/phone/ets/pages/MainPage`
        });
      } else {
        router.replaceNamedRoute({
          name: 'ThemeSettingPage',
          params: {
            firstTopic: true
          }
        });
      }
    }).catch(() => {
      router.replaceUrl({
        url: `@bundle:${bundleName}/phone/ets/pages/MainPage`
      });
    });
  }

  checkIsFirstStart(): void {
    this.preferenceManager.hasValue('isFirstStart').then((hasResult: boolean) => {
      if (hasResult) {
        Logger.info(TAG, 'Not first startup.');
        this.firstStart = false;
      } else {
        Logger.info(TAG, 'First startup.');
        this.userModel.savePushToken();
        this.preferenceManager.setValue('isFirstStart', false).then(() => {
          Logger.info(TAG, 'Put the value of startup Successfully.');
        }).catch((err: BusinessError) => {
          Logger.error(TAG, 'Put the value of startup Failed, err: ' + err);
        });
      }
    }).catch((err: BusinessError) => {
      Logger.error(TAG, 'check startup Failed, err: ' + err);
    });
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Bottom }) {
        Swiper(this.swiperController) {
          LazyForEach(this.data, (item: Resource) => {
            Image(item)
              .width(CommonConstants.FULL_PERCENT)
              .height(CommonConstants.FULL_PERCENT)
              .objectFit(ImageFit.Cover)
          })
        }
        .cachedCount(this.data.totalCount() - 1)
        .visibility(this.showSwiper ? Visibility.Visible : Visibility.Hidden)
        .loop(true)
        .autoPlay(true)
        .indicator(this.currentBreakpoint !== BreakpointTypeEnum.LG ? Indicator.dot()
          .bottom(AppStorage.get<number>('naviIndicatorHeight'))
          .itemWidth($r('app.float.splash_swiper_indicator'))
          .itemHeight($r('app.float.splash_swiper_indicator'))
          .selectedItemWidth($r('app.float.splash_swiper_indicator'))
          .selectedItemHeight($r('app.float.splash_swiper_indicator'))
          .color(Color.Gray)
          .selectedColor(Color.White) : false)
        .displayArrow(this.currentBreakpoint === BreakpointTypeEnum.LG ? {
          showBackground: true,
          isSidebarMiddle: true,
          arrowColor: $r('app.color.color_white'),
          backgroundColor: $r('app.color.arrow_bg_white')
        } : false)
        .onChange((index: number) => {
          this.current_swiper.index = index;
        })
        .curve(Curve.Linear)

        Button({ type: ButtonType.Capsule, stateEffect: true }) {
          Text($r('app.string.splash_button_title'))
            .fontFamily($r('app.string.topic_title_family_sub'))
            .fontColor($r('app.color.color_white'))
            .fontSize($r('app.float.splash_normal_text_size'))
            .fontWeight(SplashConstants.BUTTON_FONT_WEIGHT)
            .opacity(SplashConstants.BUTTON_TEXT_OPACITY)
        }
        .visibility(this.showSwiper ? Visibility.Visible : Visibility.Hidden)
        .backgroundColor($r('app.color.backgroundColor'))
        .width(new BreakpointType<Length>({
          sm: '86.7%',
          md: '45%',
          lg: '31%'
        }).getValue(this.currentBreakpoint))
        .height($r('app.float.button_height'))
        .onClick(() => this.jump())
        .borderRadius($r('app.float.button_borderRadius'))
        .backdropBlur(SplashConstants.BUTTON_BLUR)
        .margin({ bottom: 64 })


        Column() {
          Column() {
            Image($r('app.media.ic_splash'))
              .width($r('app.float.image_width'))
              .aspectRatio(1)
              .objectFit(ImageFit.Contain)
              .transition(TransitionEffect.asymmetric(TransitionEffect.OPACITY.animation({
                duration: SplashConstants.SPLASH_ICON_OPACITY_DURATION,
                curve: Curve.Ease
              }), TransitionEffect.OPACITY.animation({
                duration: 0
              })))
          }
          .width(this.currentBreakpoint === BreakpointTypeEnum.LG ? SplashConstants.PERCENT_67 :
          CommonConstants.FULL_PERCENT)
          .aspectRatio(this.currentBreakpoint === BreakpointTypeEnum.SM ? 2 / 3 : 3 / 2)
          .backgroundImageSize({
            width: this.currentBreakpoint === BreakpointTypeEnum.SM ? '225%' : CommonConstants.FULL_PERCENT,
            height: CommonConstants.FULL_PERCENT
          })
          .backgroundImage($r('app.media.bg_splash'))
          .backgroundImagePosition(Alignment.Center)
          .justifyContent(FlexAlign.Center)

          Column() {
            Text($r('app.string.splash_main_title'))
              .fontFamily($r('app.string.topic_title_family_sub'))
              .fontColor($r('app.color.color_white'))
              .fontSize($r('app.float.splash_title_text_size'))
              .fontWeight(SplashConstants.BUTTON_FONT_WEIGHT)

            Text($r('app.string.splash_sub_title'))
              .fontFamily($r('app.string.topic_title_family_sub'))
              .fontSize($r('app.float.splash_normal_text_size'))
              .fontColor($r('app.color.color_white'))
              .opacity(SplashConstants.TEXT_OPACITY)
              .fontWeight(SplashConstants.TEXT_FONT_WEIGHT)
              .margin({
                top: $r('app.float.tab_title_margin')
              })
          }
          .transition(TransitionEffect.asymmetric(TransitionEffect.OPACITY.animation({
            duration: SplashConstants.SPLASH_OPACITY_DURATION,
            curve: Curve.Ease
          }), TransitionEffect.OPACITY.animation({
            duration: 0
          })))
        }
        .padding({ bottom: '17%', top: $r('app.float.xxl_padding_margin') })
        .justifyContent(FlexAlign.SpaceBetween)
        .backgroundColor($r('app.color.theme_blue_color'))
        .height(CommonConstants.FULL_PERCENT)
        .width(CommonConstants.FULL_PERCENT)
        .visibility(this.showSwiper ? Visibility.Hidden : Visibility.Visible)
      }
    }
    .height(CommonConstants.FULL_PERCENT)
    .width(CommonConstants.FULL_PERCENT)
  }
}