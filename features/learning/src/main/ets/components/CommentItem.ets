/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { LearningConstants } from '../constants/LearningConstants';
import { LearningComment } from '../model/LearningComment';

@Reusable
@Component
export struct CommentItem {
  @State item: LearningComment = new LearningComment();

  aboutToReuse(params: Record<string, Object>): void {
    this.item = params.item as LearningComment;
  }

  build() {
    Row() {
      Image($r('app.media.ic_user_default'))
        .width($r('app.float.achieve_btn_height'))
        .aspectRatio(1)
      Column() {
        Row() {
          Text($r('app.string.commenter'))
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
            .fontSize($r('app.float.btn_font_size'))
            .fontWeight(FontWeight.Medium)
            .lineHeight($r('app.float.comment_user_line_height'))
          Image($r('app.media.ic_more'))
            .fillColor($r('sys.color.ohos_id_color_foreground'))
            .width($r('app.float.achieve_close_icon_size'))
        }
        .width(LearningConstants.FULL_PERCENT)
        .justifyContent(FlexAlign.SpaceBetween)

        Text(this.item.createTime)
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .fontSize($r('app.float.font_size_normal'))
          .lineHeight($r('app.float.time_line_height'))
        Row() {
          ForEach([0, 1, 2, 3, 4], (scoreItem: number) => {
            Image(scoreItem < this.item.score ? $r('app.media.ic_star_on') : $r('app.media.ic_star_off'))
              .width($r('app.float.star_icon_width'))
              .margin({ right: $r('app.float.sm_padding_margin') })
              .aspectRatio(1)
          })
          Text(this.item.score.toFixed(1))
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
            .fontSize($r('app.float.font_size_normal'))
            .fontWeight(FontWeight.Medium)
            .lineHeight($r('app.float.comment_line_height'))
        }
        .margin({ top: $r('app.float.sm_padding_margin'), bottom: $r('app.float.sm_padding_margin') })

        Text(this.item.comment)
          .lineHeight($r('app.float.comment_line_height'))
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .fontSize($r('app.float.font_size_normal'))
          .fontWeight(FontWeight.Medium)
        Divider()
          .margin({ top: $r('app.float.md_padding_margin') })
          .height($r('app.float.divider_height'))
          .color($r('sys.color.ohos_id_color_text_field_sub_bg'))
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .padding({ left: $r('app.float.sm_padding_margin') })
    }
    .margin({ top: $r('app.float.md_padding_margin') })
    .alignItems(VerticalAlign.Top)
  }
}