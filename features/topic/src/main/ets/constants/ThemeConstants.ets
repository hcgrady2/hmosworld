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

export const THEME_LIST: Record<string, Resource> = {
  'f001': $r('app.media.ic_harmony'),
  'f002': $r('app.media.ic_developer_story'),
  'f003': $r('app.media.ic_new_tec'),
  'f004': $r('app.media.ic_activity'),
  'f005': $r('app.media.ic_tec_some'),
  't001': $r('app.media.ic_develop_studio'),
  't002': $r('app.media.ic_ui_ability'),
  't003': $r('app.media.ic_ark_ui')
}

export class ThemeConstants {
  static readonly COLUMN_SPACE: number = 4;
  static readonly TOPIC_ICON_OFFSET_X: number = -6;
  static readonly TOPIC_ICON_OFFSET_Y: number = 6;
  static readonly TITLE_SUB_OPACITY: number = 0.6;
  static readonly Z_INDEX_TWO: number = 2;
  static readonly FULL_SIZE = '100%';
  static readonly HALF_PERCENT = '50%';
  static readonly BUTTON_MD = '50%';
  static readonly BUTTON_LG = '34%';
  static readonly PERCENT_13 = '13%';
  static readonly COLUMNS_SM: number = 3;
  static readonly COLUMNS_MD: number = 5;
  static readonly COLUMNS_LG: number = 5;
  static readonly GUTTER_12: number = 12;
  static readonly GUTTER_30: number = 30;
  static readonly GUTTER_40: number = 40;
  static readonly GRID_ROW_X: number = -25;
  static readonly GRID_ROW_Y: number = 30;
  static readonly BUTTON_OPACITY: number = 0.4;
  static readonly URL_CONTROL: string = 'firstTopic';
}