/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

@Component
export struct SearchInput {
  @Prop enableKeyboardOnFocus: boolean;
  @Prop placeholderArray: string[];
  @Link searchValue: string;
  @State placeholderIndex: number = 0;
  @State intervalId: number = 0;
  onSearch: (value: string) => void = (value) => {
  };
  onChange?: (value: string) => void = (value) => {
  };

  aboutToAppear(): void {
    this.setPlaceholder();
  }

  setPlaceholder() {
    if (this.placeholderArray) {
      this.intervalId = setInterval(() => {
        this.placeholderIndex = (this.placeholderIndex + 1) % this.placeholderArray!.length;
      }, 1500);
    }
  }

  aboutToDisappear(): void {
    clearInterval(this.intervalId);
  }

  build() {
    Search({
      placeholder: this.placeholderArray ? this.placeholderArray[this.placeholderIndex] : $r('app.string.search'),
      value: this.searchValue
    })
      .enableKeyboardOnFocus(this.enableKeyboardOnFocus)
      .textFont({ size: $r('app.float.large_text_size') })
      .placeholderFont({ size: $r('app.float.large_text_size')})
      .height($r('app.float.search_height'))
      .layoutWeight(1)
      .enterKeyType(EnterKeyType.Search)
      .onFocus(() => {
        clearInterval(this.intervalId);
      })
      .sharedTransition('sharedImage', { duration: 800, curve: Curve.Linear, delay: 100 })
      .onBlur(() => {
        this.setPlaceholder();
      })
      .onChange((value: string) => {
        this.onChange?.(value);
      })
      .onSubmit((value: string) => {
        if (this.placeholderArray?.length) {
          this.onSearch(value ? value : this.placeholderArray[this.placeholderIndex]);
        } else {
          if (!value) {
            return;
          }
          this.onSearch(value);
        }
      })
  }
}