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

import { LearningResource } from '@ohos/mine';
import { TagColorMap } from '@ohos/topic';
import { TagLabelCard } from '@ohos/uicomponents';
import { CommonConstants, CommonUtil } from '@ohos/utils';

const MAX_TOPIC_NUM: number = 2;
const AGC_SERVICE: string = 'agc-storage-drcn.platform.dbankcloud.cn';

@Reusable
@Component
export struct FeedFlowItem {
  @State feedItem: LearningResource = new LearningResource();

  aboutToReuse(params: Record<string, Object>): void {
    this.feedItem = params.feedItem as LearningResource;
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.BottomEnd }) {
        Image(this.feedItem.headerImageUrl)
          .alt($r('app.media.img_placeholder'))
          .borderRadius({
            topLeft: $r('app.float.lg_border_radius'),
            topRight: $r('app.float.lg_border_radius')
          })
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
        ViewsCountLabel({ viewsCount: this.feedItem.viewsCount })
      }
      .width(CommonConstants.FULL_PERCENT)
      .aspectRatio(this.feedItem.headerImageUrl.includes(AGC_SERVICE) ? 1.4 : 1.8)

      Text(this.feedItem.title)
        .width(CommonConstants.FULL_PERCENT)
        .height($r('app.float.hot_feed_area_height'))
        .fontSize($r('app.float.md_font_size'))
        .textAlign(TextAlign.Start)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .lineHeight($r('app.float.md_line_height'))
        .maxLines(CommonConstants.MAX_LINE_TWO)
        .padding({
          top: $r('app.float.sm_padding_margin'),
          bottom: $r('app.float.xs_padding_margin'),
          left: $r('app.float.md_padding_margin'),
          right: $r('app.float.md_padding_margin')
        })

      Row({ space: CommonConstants.SPACE_4 }) {
        if (this.feedItem.topics.length > 0) {
          ForEach(this.feedItem.topics.slice(0, MAX_TOPIC_NUM), (topic: string) => {
            TagLabelCard(topic, TagColorMap.get(topic) || '')
          }, (item: string) => item)
        }
      }
      .width(CommonConstants.FULL_PERCENT)
      .borderRadius({
        bottomLeft: $r('app.float.lg_border_radius'),
        bottomRight: $r('app.float.lg_border_radius')
      })
      .height($r('app.float.interactive_button_height'))
      .padding({
        left: $r('app.float.md_padding_margin'),
        right: $r('app.float.md_padding_margin'),
        bottom: $r('app.float.md_padding_margin')
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('app.color.hmos_article_card_color_white'))
    .borderRadius($r('app.float.lg_border_radius'))
  }
}

@Component
struct ViewsCountLabel {
  @Prop viewsCount: number = 0;

  build() {
    Row() {
      Image($r('app.media.ic_eye_open'))
        .size({ width: $r('app.float.icon_size'), height: $r('app.float.icon_size') })
        .fillColor(Color.White)
        .margin({ right: $r('app.float.xs_padding_margin') })

      Text(CommonUtil.transNumberOverOneThousand(this.viewsCount))
        .fontSize($r('app.float.sm_font_size'))
        .textAlign(TextAlign.Center)
        .fontColor(Color.White)
        .opacity(CommonConstants.FIRST_LEVEL_OPACITY)
    }
    .height($r('app.float.view_count_height'))
    .padding({ left: $r('app.float.xs_padding_margin'), right: $r('app.float.xs_padding_margin') })
    .backgroundColor($r('app.color.view_counts_bg_color'))
    .borderRadius($r('app.float.md_border_radius'))
    .margin({ right: $r('app.float.sm_padding_margin'), bottom: $r('app.float.sm_padding_margin') })
  }
}