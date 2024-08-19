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

import { TagColorMap } from '@ohos/topic';
import { TagLabelCard } from '@ohos/uicomponents';
import { CommonConstants } from '@ohos/utils';
import Constants from '../constants/Constants';
import { LearningResource } from '../model/LearningResource';

@Reusable
@Component
export struct FeedCardView {
  @State articleItem: LearningResource = new LearningResource();
  @Prop isSelected?: boolean = false;

  aboutToReuse(params: Record<string, Object>): void {
    this.articleItem = params.articleItem as LearningResource;
  }

  build() {
    Row({ space: CommonConstants.SPACE_16 }) {
      Column() {
        Column() {
          Text(this.articleItem.title)
            .fontSize($r('app.float.title_font_size'))
            .fontFamily(CommonConstants.HARMONY_HEI_TI_FONT_FAMILY)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .opacity(CommonConstants.FIRST_LEVEL_OPACITY)
            .maxLines(CommonConstants.MAX_LINE_TWO)
            .margin({ bottom: $r('app.float.ss_padding_margin') })

          Text(this.articleItem.brief)
            .fontSize($r('app.float.brief_font_size'))
            .fontFamily(CommonConstants.HARMONY_HEI_TI_FONT_FAMILY)
            .opacity(CommonConstants.SECOND_LEVEL_OPACITY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .textAlign(TextAlign.Start)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Row({ space: Constants.SMALL_SPACE }) {
          ForEach(this.articleItem.topics, (topic: string) => {
            TagLabelCard(topic, TagColorMap.get(topic) || '')
          }, (item: string) => item)
        }
        .width(CommonConstants.FULL_PERCENT)
        .justifyContent(FlexAlign.Start)
      }
      .layoutWeight(1)
      .height(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceAround)

      Stack({ alignContent: Alignment.BottomEnd }) {
        Image(this.articleItem.headerImageUrl)
          .height($r('app.float.resource_image_height'))
          .width($r('app.float.resource_image_width'))
          .borderRadius($r('app.float.image_border_radius'))
          .alt($r('app.media.img_placeholder'))
          .objectFit(ImageFit.Cover)
        Text($r('app.string.feed'))
          .fontSize($r('app.float.small_font_size'))
          .margin({
            right: $r('app.float.resource_type_font_padding'),
            bottom: $r('app.float.resource_type_font_padding')
          })
          .padding({
            left: $r('app.float.resource_type_font_margin_left_right'),
            right: $r('app.float.resource_type_font_margin_left_right'),
            top: $r('app.float.resource_type_font_margin_top_bottom'),
            bottom: $r('app.float.resource_type_font_margin_top_bottom')
          })
          .backgroundColor($r('app.color.hmos_regular_gray'))
          .borderRadius($r('app.float.resource_type_font_border_radius'))
          .fontColor($r('app.color.hmos_font_color_white'))
      }
      .height($r('app.float.resource_image_height'))
      .width($r('app.float.resource_image_width'))
    }
    .padding($r('app.float.md_padding_margin'))
    .borderRadius($r('app.float.large_border_radius'))
    .backgroundColor($r('app.color.hmos_article_card_color_white'))
    .alignItems(VerticalAlign.Top)
    .width(CommonConstants.FULL_PERCENT)
    .height($r('app.float.card_height'))
    .linearGradient(this.isSelected ? {
      angle: '90deg',
      colors: [[$r('app.color.selected_color_left'), 0], [$r('app.color.selected_color_right'), 1]]
    } : { colors: [] })
  }
}