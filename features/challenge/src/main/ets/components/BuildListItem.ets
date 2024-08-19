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

import { image } from '@kit.ImageKit';
import { BreakpointType, BreakpointTypeEnum, ImageUtil } from '@ohos/utils';
import ZonesItem from '../model/ZonesItem';
import { ChallengeConstants as Const } from '../constants/ChallengeConstants';

@Component
export default struct BuildListItem {
  @Consume('introductionData') introductionData: ZonesItem;
  @Prop buildingImgRatio: number = 0;
  currentBreakpoint: string = BreakpointTypeEnum.SM;
  @State imagePixelMap: image.PixelMap | undefined = undefined;

  async aboutToAppear() {
    this.imagePixelMap =await ImageUtil.getPixmapFromMedia(this.introductionData.buildingPic);
  }

  build() {
    Column() {
      Image(this.introductionData.starLinePic[1])
        .width(new BreakpointType<Length>({
          sm: Const.PERCENT_86,
          md: Const.PERCENT_70,
          lg: Const.PERCENT_47
        }).getValue(this.currentBreakpoint))
        .margin({ bottom: $r('app.float.introduction_star_line_margin') })
      Text(this.introductionData.buildingInformation)
        .width(new BreakpointType<Length>({
          sm: Const.PERCENT_86,
          md: Const.PERCENT_93,
          lg: Const.PERCENT_63
        }).getValue(this.currentBreakpoint))
        .fontSize($r('app.float.font_size_normal'))
        .letterSpacing(0)
      Column() {
        Image(this.imagePixelMap)
          .enableAnalyzer(true)
          .width(Const.FULL_PERCENT)
          .aspectRatio(Const.BUILD_TOP_ASPECT_RATIO)
          .margin({ top: `${-this.buildingImgRatio * Const.BUILDING_COEFFICIENT}%` })
      }
      .width(new BreakpointType<Length>({
        sm: Const.FULL_PERCENT,
        md: Const.PERCENT_70,
        lg: Const.PERCENT_47
      }).getValue(this.currentBreakpoint))
      .aspectRatio(Const.BUILDING_ASPECT_RATIO)
      .borderRadius($r('app.float.introduction_image_border_radius'))
      .margin({ top: $r('app.float.introduction_image_margin') })
      .clip(true)
    }
    .width(Const.FULL_PERCENT)
    .padding({ top: $r('app.float.xxl_padding_margin'), bottom: $r('app.float.xxl_padding_margin') })
  }
}