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

import { BreakpointType, BreakpointTypeEnum, CommonConstants } from '@ohos/utils';
import { ArticleLoadingSkeleton } from '@ohos/uicomponents';
import { SkeletonData, SkeType } from '../constants/Constants';

@Component
export struct LoadingView {
  @State columnBgColor: Color = Color.Gray;
  @State listOpacity: number = 1;
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;

  startAnimation(): void {
    animateTo(CommonConstants.SKELETON_ANIMATION, () => {
      this.listOpacity = CommonConstants.HALF_OPACITY;
    });
  }

  build() {
    Row() {
      List({ space: CommonConstants.SPACE_12 }) {
        ForEach(SkeletonData, (item: SkeType) => {
          ListItem() {
            ArticleLoadingSkeleton(item.isMine, item.isFeed)
          }
        })
      }
      .padding({
        left: new BreakpointType({
          sm: $r('app.float.md_padding_margin'),
          md: $r('app.float.xxl_padding_margin'),
          lg: $r('app.float.xxl_padding_margin')
        }).getValue(this.currentBreakpoint),
        right: new BreakpointType<Length>({
          sm: 0,
          md: $r('app.float.md_padding_margin'),
          lg: 0
        }).getValue(this.currentBreakpoint)
      })
      .lanes(new BreakpointType({ sm: 1, md: 2, lg: 1 }).getValue(this.currentBreakpoint))
      .layoutWeight(4)
      .scrollBar(BarState.Off)
      .padding({
        left: new BreakpointType({
          sm: $r('app.float.md_padding_margin'),
          md: $r('app.float.xxl_padding_margin'),
          lg: $r('app.float.xxl_padding_margin')
        }).getValue(this.currentBreakpoint),
        right: new BreakpointType<Length>({
          sm: 0,
          md: $r('app.float.md_padding_margin'),
          lg: 0
        }).getValue(this.currentBreakpoint)
      })

      Row()
        .layoutWeight(this.currentBreakpoint === BreakpointTypeEnum.LG ? 6 : 0)
        .backgroundColor($r('app.color.skeleton_color_medium'))
    }
    .alignItems(VerticalAlign.Top)
    .height(CommonConstants.FULL_PERCENT)
    .width(CommonConstants.FULL_PERCENT)
    .opacity(this.listOpacity)
    .onAppear(() => {
      this.startAnimation();
    })
  }
}