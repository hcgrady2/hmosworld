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
import { LearningPath } from '../model/LearningPath';

const IMG_ASPECT_RATIO: number = 1.78;
const MAX_LINES: number = 2;
const SPACE: number = 4;

@Builder
export function LearningItem(learningItem: LearningPath) {
  Column() {
    Image(learningItem.thumbnail)
      .width(LearningConstants.FULL_PERCENT)
      .aspectRatio(IMG_ASPECT_RATIO)
    Column({ space: SPACE }) {
      Text(learningItem.title)
        .textAlign(TextAlign.Start)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(1)
        .fontSize($r('app.float.font_size_normal'))
        .width(LearningConstants.FULL_PERCENT)
      Text(learningItem.brief)
        .textAlign(TextAlign.Start)
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontSize($r('app.float.font_size_small'))
        .maxLines(MAX_LINES)
        .width(LearningConstants.FULL_PERCENT)
    }
    .width(LearningConstants.FULL_PERCENT)
    .padding($r('app.float.md_padding_margin'))
  }
  .clip(true)
  .borderRadius($r('app.float.common_border_radius'))
  .backgroundColor($r('app.color.learning_item_background_color'))
  .width(LearningConstants.FULL_PERCENT)
}