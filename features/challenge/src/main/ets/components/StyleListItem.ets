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
import ZonesItem from '../model/ZonesItem';
import { ChallengeConstants as Const } from '../constants/ChallengeConstants';
import DesignStyleSwiper from './DesignStyleSwiper';

@Component
export default struct StyleListItem {
  @Consume('introductionData') introductionData: ZonesItem;
  currentBreakpoint: string = BreakpointTypeEnum.SM;

  build() {
    Column() {
      ForEach(this.introductionData.content, (item: string) => {
        Text(item)
          .width(new BreakpointType<Length>({
            sm: Const.PERCENT_86,
            md: Const.PERCENT_93,
            lg: Const.PERCENT_63
          }).getValue(this.currentBreakpoint))
          .fontSize($r('app.float.font_size_normal'))
          .margin({ bottom: $r('app.float.xxl_padding_margin') })
      }, (item: ResourceStr) => JSON.stringify(item))
      Column() {
        DesignStyleSwiper()
      }
      .margin({
        top: $r('app.float.xxl_padding_margin'),
        bottom: $r('app.float.xxl_padding_margin')
      })
    }
    .width(Const.FULL_PERCENT)
    .padding({ top: $r('app.float.xxl_padding_margin'), bottom: $r('app.float.xxl_padding_margin') })
  }
}