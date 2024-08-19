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

import { CommonConstants, CommonUtil } from '@ohos/utils';
import { Constants } from '../common/Constants';

@Builder
export function EyeCountComponent(count: number) {
  Row() {
    Image($r('app.media.ic_eye_open'))
      .fillColor($r('sys.color.ohos_id_color_text_secondary'))
      .width($r('app.float.icon_size'))
      .aspectRatio(1)
      .margin({ right: $r('app.float.xs_padding_margin') })
    Text(CommonUtil.transNumberOverOneThousand(count))
      .fontColor($r('sys.color.ohos_id_color_text_secondary'))
      .fontSize($r('app.float.small_text_size'))
      .width($r('app.float.view_count_icon_width'))
      .opacity(Constants.SECOND_LEVEL_OPACITY)
  }
  .width($r('app.float.action_button_width'))
  .padding({ top: $r('app.float.sm_padding_margin'), bottom: $r('app.float.sm_padding_margin') })
  .alignItems(VerticalAlign.Center)
  .justifyContent(FlexAlign.Center)
}