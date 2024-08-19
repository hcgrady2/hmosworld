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

import { BreakpointType, BreakpointTypeEnum } from '@ohos/utils';
import { ChallengeConstants as Const } from '../constants/ChallengeConstants';
import ZonesItem from '../model/ZonesItem';

const ASPECT_MD: number = 0.7;
const ASPECT_LG: number = 0.47;

@Component
export default struct SubTitleItem {
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.SM;
  @State deviceWidth: number =
    this.currentBreakpoint === BreakpointTypeEnum.SM ? (AppStorage.get('deviceWidth') as number) : 360;
  @State imgHeight: number = Math.ceil(this.deviceWidth / Const.TOP_IMG_ASPECT);
  @Consume('introductionData') introductionData: ZonesItem;
  @Prop topImgOffset: number = 0;

  build() {
    Column() {
      Text(this.introductionData.title)
        .fontSize($r('app.float.navigation_title_size'))
        .fontColor($r('app.color.white'))
        .fontWeight(FontWeight.Medium)
        .margin({ top: $r('app.float.zone_title_margin') })
      Text(this.introductionData.subTitle)
        .fontSize($r('app.float.font_size_normal'))
        .margin({ bottom: $r('app.float.xxl_padding_margin'), top: $r('app.float.sm_padding_margin') })
        .fontColor($r('app.color.desc_white_font_color'))
      Image(this.introductionData.starLinePic[0])
        .height($r('app.float.star_img_height'))
        .aspectRatio(Const.STAR_IMG_ASPECT)
      Column() {
        Text(this.introductionData.createTime)
          .fontSize($r('app.float.font_size_normal'))
          .fontColor($r('app.color.desc_white_font_color'))
      }
      .padding({ top: $r('app.float.md_padding_margin'), bottom: $r('app.float.zone_desc_margin') })
      .backgroundColor(this.introductionData.backgroundColor)
      .zIndex(2)

      Stack({ alignContent: Alignment.Top }) {
        Image(this.introductionData.subPicMedium)
          .offset({ x: 0, y: -this.topImgOffset })
          .width(new BreakpointType<Length>({
            sm: Const.FULL_PERCENT,
            md: Const.PERCENT_70,
            lg: Const.PERCENT_47
          }).getValue(BreakpointTypeEnum.SM))
          .height(Math.floor(this.deviceWidth * new BreakpointType<number>({
            sm: 1,
            md: ASPECT_MD,
            lg: ASPECT_LG
          }).getValue(BreakpointTypeEnum.SM) / Const.TOP_IMG_ASPECT))
          .objectFit(ImageFit.Fill)
        Image(this.introductionData.subPicTop)
          .objectFit(ImageFit.Cover)
          .width(new BreakpointType<Length>({
            sm: Const.FULL_PERCENT,
            md: Const.PERCENT_70,
            lg: Const.PERCENT_47
          }).getValue(BreakpointTypeEnum.SM))
      }
      .width(Const.FULL_PERCENT)
      .height(Math.floor(this.deviceWidth * new BreakpointType<number>({
        sm: 1,
        md: ASPECT_MD,
        lg: ASPECT_LG
      }).getValue(BreakpointTypeEnum.SM) / Const.TOP_IMG_ASPECT - this.topImgOffset))
      .clip(true)
    }
    .width(Const.FULL_PERCENT)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(this.introductionData.backgroundColor)
  }
}