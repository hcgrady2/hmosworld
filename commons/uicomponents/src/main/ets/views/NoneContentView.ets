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

import { CommonConstants } from '@ohos/utils/';

@Builder
export function NoneContentView(imgSrc: Resource, description: Resource) {
  Column({ space: CommonConstants.SPACE_8 }) {
    Image(imgSrc)
      .size({ width: $r('app.float.none_view_image_size'), height: $r('app.float.none_view_image_size') })
    Text(description)
      .fontColor($r('sys.color.ohos_id_color_text_secondary'))
      .fontSize($r('app.float.normal_text_size1'))
  }
  .alignItems(HorizontalAlign.Center)
  .justifyContent(FlexAlign.Center)
  .width(CommonConstants.FULL_PERCENT)
  .layoutWeight(1)
}