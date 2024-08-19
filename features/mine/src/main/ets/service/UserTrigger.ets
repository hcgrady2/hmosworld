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

/*
 * Cloud function trigger.
 */
export enum UserTrigger {

  // Mine module - Get user data
  USER_DATA = 'user-data',

  // Mine Modules - Get List of Favorites
  COLLECT = 'collect',
  // Mine Module - Get Browsing History List
  HISTORY = 'history',
  // Mine Modules - Achievements
  ACHIEVE = 'achieve',

  // Discovery Module - Like
  LIKE = 'like',
  // Discovery Module - Favorites
  COLLECT_MODIFY = 'collect-modify',

  // save push token
  PUSH_TOKEN = 'set-push-token',
}