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

import { Constants } from '../constants/LoginConstants';
import { AccountSelectView } from './AccountSelectView';

@Component
export struct InputAreaView {
  @Link username: string;
  @Link curIndex: number;
  @Link password: string;

  @Builder
  AccountMenuBuilder() {
    AccountSelectView({
      username: this.username
    })
  }

  build() {
    Column() {
      Stack() {
        TextInput({
          text: this.username,
          placeholder: $r('app.string.account_placeholder')
        })
          .inputStyle()
          .onChange(value => {
            this.username = value;
          })
          .fontColor(Color.White)
          .margin({ right: $r('app.float.text_input_margin_right') })
          .enableKeyboardOnFocus(false)

        Row() {
          Image($r('app.media.ic_arrow'))
            .width($r('app.float.normal_icon_size'))
            .height($r('app.float.normal_icon_size'))
        }
        .width($r('app.float.show_list_width'))
        .height($r('app.float.show_list_height'))
        .borderRadius($r('app.float.show_list_border_radius'))
        .margin({ right: $r('app.float.login_spinner_margin_right') })
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .bindMenu(this.AccountMenuBuilder)
      }
      .alignContent(Alignment.End)

      this.TextLine()

      TextInput({
        text: this.password,
        placeholder: $r('app.string.password')
      })
        .inputStyle()
        .type(InputType.Password)
        .onChange(value => {
          this.password = value;
        })
        .fontColor(Color.White)
        .margin({
          top: $r('app.float.text_input_margin_top'),
          right: $r('app.float.text_input_margin_right')
        })
        .passwordIcon({
          onIconSrc: $r('app.media.ic_eye_open'),
          offIconSrc: $r('app.media.ic_eye_close')
        })

      this.TextLine()
    }
    .width(Constants.FULL_SCREEN)
    .margin({ top: $r('app.float.input_margin_top') })
  }

  @Builder
  TextLine() {
    Line()
      .height($r('app.float.line_height'))
      .width(Constants.FULL_SCREEN)
      .backgroundColor($r('app.color.line_background_color'))
      .padding({
        left: $r('app.float.md_padding_margin'),
        right: $r('app.float.md_padding_margin')
      })
  }
}

@Extend(TextInput)
function inputStyle() {
  .width(Constants.FULL_SCREEN)
  .height($r('app.float.text_input_height'))
  .maxLength(Constants.MAX_LENGTH)
  .placeholderColor($r('app.color.text_input_placeholder_color'))
  .backgroundColor($r('app.color.text_input_background_color'))
}