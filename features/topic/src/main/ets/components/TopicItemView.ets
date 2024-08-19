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
import { THEME_LIST, ThemeConstants } from '../constants/ThemeConstants';
import { Topic } from '../model/Topic';

@Component
export struct TopicItemView {
  @Prop item: Topic;
  @State isSelected: boolean = this.item.isFollowed;
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;
  handleClick?: () => void;

  build() {
    Button({ type: ButtonType.Normal }) {
      Stack({ alignContent: Alignment.TopEnd }) {
        Image($r('app.media.ic_checked'))
          .width(new BreakpointType({
            sm: $r('app.float.topic_icon_size_md'),
            md: $r('app.float.topic_icon_size_md'),
            lg: $r('app.float.topic_icon_size_lg')
          }).getValue(this.currentBreakpoint))
          .aspectRatio(1)
          .offset({ x: ThemeConstants.TOPIC_ICON_OFFSET_X, y: ThemeConstants.TOPIC_ICON_OFFSET_Y })
          .zIndex(ThemeConstants.Z_INDEX_TWO)
          .animation({})
          .visibility(this.isSelected ? Visibility.Visible : Visibility.Hidden)

        Column({ space: ThemeConstants.COLUMN_SPACE }) {
          Image(THEME_LIST[this.item.id])
            .interpolation(ImageInterpolation.High)
            .width(new BreakpointType({
              sm: $r('app.float.topic_image_size_md'),
              md: $r('app.float.topic_image_size_md'),
              lg: $r('app.float.topic_image_size_lg')
            }).getValue(this.currentBreakpoint))
            .aspectRatio(1)
          Text(this.item.name)
            .topicTitleStyle()
        }
        .width(ThemeConstants.FULL_SIZE)
        .height(ThemeConstants.FULL_SIZE)
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
      }
      .width(ThemeConstants.FULL_SIZE)
      .height(ThemeConstants.FULL_SIZE)
    }
    .animation({})
    .borderWidth(this.isSelected ? $r('app.float.topic_icon_border') : 0)
    .borderColor(this.isSelected ? $r('app.color.btn_bg') : $r('app.color.item_white_bg'))
    .borderRadius($r('app.float.topic_border'))
    .backgroundColor($r('app.color.item_white_bg'))
    .width(new BreakpointType({
      sm: $r('app.float.topic_size_md'),
      md: $r('app.float.topic_size_md'),
      lg: $r('app.float.topic_size_lg')
    }).getValue(this.currentBreakpoint))
    .aspectRatio(1)
    .onClick(() => {
      this.isSelected = !this.isSelected;
      this.handleClick?.();
    })
  }
}

@Extend(Text)
function topicTitleStyle() {
  .fontFamily($r('app.string.topic_title_main_family'))
  .fontWeight(FontWeight.Medium)
  .fontColor($r('app.color.topic_color'))
  .fontSize($r('app.float.topic_title_font'))
}