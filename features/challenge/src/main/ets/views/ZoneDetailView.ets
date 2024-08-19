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

import { BreakpointTypeEnum, Logger } from '@ohos/utils';
import ZonesItem from '../model/ZonesItem';
import { ChallengeConstants as Const } from '../constants/ChallengeConstants';
import { ICON_SUBTITLE_ARRAY, IconSubtitle } from '../model/IconSubtitleData';
import BuildListItem from '../components/BuildListItem';
import StyleListItem from '../components/StyleListItem';
import SubTitleItem from '../components/SubTitleItem';
import { ChallengeItemBuilder } from '../components/ChallengeItem';
import LocationItem from '../components/LocationItem';

const TAG: string = '[ZoneDetailView]';
const MAX_IMG_RATIO: number = 0.15;

@Component
export struct ZoneDetailView {
  @Consume('appPathStack') appPathStack: NavPathStack;
  private scroller: Scroller = new Scroller();
  @StorageProp('deviceWidth') @Watch('handleBreakpointChange') deviceWidth: number =
    AppStorage.get('deviceWidth') as number;
  @StorageProp('deviceHeight') imageMaxHeight: number = AppStorage.get('deviceHeight') as number;
  @State imageHeight: number = this.imageMaxHeight;
  @State imageMinHeight: number = 0;
  detailSheetMinHeight: number = 0;
  detailSheetMaxHeight: number = 0;
  @Link @Watch('changeImageHeight') detailSheetHeight: number;
  @State arrowIconOpacity: number = 0;
  @State isReachStart: boolean = false;
  @State currentStyleIndex: number = 0;
  @Consume('introductionData') introductionData: ZonesItem;
  @State topImgOffset: number = 0;
  @State locationImgScale: number = 0;
  @StorageProp('currentBreakpoint') @Watch('handleBreakpointChange') currentBreakpoint: string = BreakpointTypeEnum.SM;

  getRatios(): number[] {
    let ratio: number = 0;
    let arr: number[] = [0];
    while (ratio < 1) {
      ratio += 0.01;
      arr.push(ratio);
    }
    return arr;
  }

  changeImageHeight() {
    this.imageHeight =
      this.detailSheetHeight > this.detailSheetMinHeight ? (this.detailSheetHeight - Const.MODAL_BOTTOM_HEIGHT) :
        (this.detailSheetMinHeight - Const.MODAL_BOTTOM_HEIGHT);
    this.currentStyleIndex = 0;
    this.arrowIconOpacity = this.detailSheetMinHeight === this.detailSheetHeight ? 0 : 1;
  }

  aboutToAppear() {
    this.handleBreakpointChange();
    this.arrowIconOpacity = 0;
  }

  handleBreakpointChange() {
    this.imageMaxHeight = this.detailSheetMaxHeight - 96;
    this.imageMinHeight = Math.floor((this.currentBreakpoint === BreakpointTypeEnum.SM ?
    this.deviceWidth : Const.MODAL_MAX_WIDTH) * Const.IMG_ASPECT_RATIO);
    this.imageHeight = this.imageMinHeight;
  }

  handleVisibleAreaChange(isVisible: boolean, currentRatio: number) {
    Logger.info('StyleListItem isVisible: ' + isVisible + ', currentRatio:' + currentRatio);
    if (isVisible) {
      this.currentStyleIndex = currentRatio > 0.8 ? 2 : 1;
    } else {
      this.currentStyleIndex = currentRatio > 0.2 ? 1 : 0;
    }
  }

  handleScrollFrame(offset: number): number {
    let tempImgHeight: number = Math.ceil(this.imageHeight - offset);
    let yOffset: number = this.scroller.currentOffset().yOffset;
    Logger.info(TAG, 'yOffset： ' + offset + '   Height： ' + (this.imageMaxHeight - this.imageMinHeight));
    if (yOffset > 0) {
      Logger.info(TAG, 'unHandle Image');
      this.imageHeight = this.imageMinHeight;
      return offset;
    }
    if (tempImgHeight >= this.imageMinHeight && tempImgHeight <= this.imageMaxHeight) {
      Logger.info(TAG, 'scale Image');
      this.imageHeight = tempImgHeight;
      this.arrowIconOpacity = (this.imageHeight - this.imageMinHeight) / (this.imageMaxHeight - this.imageMinHeight);
      return 0;
    }
    if (tempImgHeight < this.imageMinHeight) {
      Logger.info(TAG, 'min Image');
      this.imageHeight = this.imageMinHeight;
      return (this.imageMinHeight - tempImgHeight);
    }
    if (tempImgHeight > this.imageMaxHeight) {
      Logger.info(TAG, 'max Image');
      this.imageHeight = this.imageMaxHeight;
      return (this.imageMaxHeight - tempImgHeight);
    }
    return offset;
  }

  /**
   * Click the up arrow scroll to the beginning.
   */
  scrollToTop() {
    this.scroller.scrollTo({
      xOffset: 0,
      yOffset: 0,
      animation: {
        duration: Const.IMAGE_ANIMATION_DURATION,
        curve: Curve.Linear,
      }
    });
    animateTo({
      duration: Const.IMAGE_ANIMATION_DURATION,
    }, () => {
      this.arrowIconOpacity = 1;
      this.imageHeight = this.imageMaxHeight;
      this.currentStyleIndex = 0;
    });
  }

  @Builder
  StyleTitle(item: IconSubtitle, index: number) {
    Column() {
      Image(item.icon)
        .width($r('app.float.title_icon_width'))
        .aspectRatio(1)
        .objectFit(ImageFit.Contain)
      Text(item.title)
        .fontSize($r('app.float.small_font_size'))
        .fontColor($r('sys.color.ohos_id_color_titlebar_subtitle_text'))
        .margin({ top: $r('app.float.title_style_margin'), bottom: $r('app.float.title_style_margin') })
        .fontWeight(FontWeight.Medium)
      Text(item.enTitle)
        .fontSize($r('app.float.smaller_font_size'))
        .fontColor($r('sys.color.ohos_id_color_titlebar_subtitle_text'))
        .margin({ bottom: $r('app.float.icon_title_margin_bottom') })
        .fontWeight(FontWeight.Bold)
    }
    .margin({ top: $r('app.float.style_margin_top') })
    .scale({ x: this.currentStyleIndex === index ? 1 : 0 })
    .opacity(this.currentStyleIndex === index ? 1 : 0)
    .animation({
      duration: Const.TITLE_ICON_ANIMATION_DURATION,
      curve: Curve.EaseOut
    })
  }

  @Builder
  StickyHeader() {
    Column() {
      Column() {
        Image(this.introductionData.subPicBottom)
          .width(Const.FULL_PERCENT)
          .aspectRatio(Const.HEAD_IMG_ASPECT)
          .objectFit(ImageFit.Fill)
      }
      .width(Const.FULL_PERCENT)
      .backgroundColor(this.introductionData.backgroundColor)
      .margin({ top: $r('app.float.intro_margin_top') })

      Image(this.introductionData.titleIcon)
        .margin({ top: $r('app.float.xxl_padding_margin') })
        .width($r('app.float.introduction_title_icon_width'))
        .height($r('app.float.introduction_title_icon_height'))
      Stack() {
        ForEach(ICON_SUBTITLE_ARRAY, (item: IconSubtitle, index?: number) => {
          if (index !== undefined) {
            this.StyleTitle(item, index)
          }
        })
      }
    }
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        List({ scroller: this.scroller }) {
          ListItem() {
            Stack({ alignContent: Alignment.Bottom }) {
              Image(this.introductionData.swiperPic)
                .width(Const.FULL_PERCENT)
                .height(this.imageHeight)
                .objectFit(ImageFit.Cover)
              Column() {
                Text(this.introductionData.title)
                  .fontSize($r('app.float.zone_title_size'))
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.white'))
                  .margin({
                    top: $r('app.float.sm_padding_margin'),
                    bottom: $r('app.float.arrow_down_margin')
                  })
                Image($r('app.media.ic_arrow_down'))
                  .height($r('app.float.smaller_font_size'))
                  .width($r('app.float.arrow_down_width'))
              }
              .width(Const.FULL_PERCENT)
              .margin({ bottom: $r('app.float.arrow_down_margin') })
              .opacity(this.detailSheetHeight >= this.detailSheetMaxHeight ? this.arrowIconOpacity : 0)
              .animation({
                duration: Const.ANIMATION_DURATION_NORMAL,
                curve: Curve.EaseOut,
              })
            }
          }

          ListItem() {
            SubTitleItem({ topImgOffset: this.topImgOffset })
          }

          ListItemGroup({ header: this.StickyHeader() }) {
            ListItem() {
              StyleListItem()
            }
            .onVisibleAreaChange(this.getRatios(), (isVisible: boolean, currentRatio: number) => {
              Logger.info(TAG, 'StyleListItem isVisible: ' + isVisible + ', currentRatio:' + currentRatio);
              if (currentRatio <= Const.HALF_NUMBER) {
                this.topImgOffset = Math.ceil(currentRatio * Const.IMG_COEFFICIENT);
              }
            })

            ListItem() {
              BuildListItem({ buildingImgRatio: Math.min(this.locationImgScale, MAX_IMG_RATIO) })
            }

            ListItem() {
              Column() {
                LocationItem({ imgScale: this.locationImgScale })
                ChallengeItemBuilder(BreakpointTypeEnum.SM, () => {
                  this.appPathStack.pushPathByName('ChallengeDetailView', undefined);
                })
              }
              .onVisibleAreaChange(this.getRatios(), (isVisible: boolean, currentRatio: number) => {
                this.locationImgScale = currentRatio;
                this.handleVisibleAreaChange(isVisible, currentRatio);
              })
            }
          }
        }
        .width(Const.FULL_PERCENT)
        .height(Const.FULL_PERCENT)
        .edgeEffect(EdgeEffect.None)
        .enableScrollInteraction(this.detailSheetHeight >= this.detailSheetMaxHeight)
        .scrollBar(BarState.Off)
        .sticky(StickyStyle.Header)
        .onScrollFrameBegin((offset: number) => {
          return { offsetRemain: this.handleScrollFrame(offset) };
        })
      }
      .height(Const.FULL_PERCENT)

      Image($r('app.media.ic_up_icon'))
        .height($r('app.float.page_icon_size'))
        .aspectRatio(1)
        .opacity(this.detailSheetHeight === this.detailSheetMaxHeight ? (1 - this.arrowIconOpacity) : 0)
        .position({
          x: Const.PERCENT_87,
          y: Const.PERCENT_90
        })
        .onClick(() => {
          this.scrollToTop();
        })
    }
    .width(Const.FULL_PERCENT)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .height(Const.FULL_PERCENT)
  }
}