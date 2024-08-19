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

import { image } from '@kit.ImageKit';
import { ResourcesType } from '@ohos/utils';

export class Topic {
  /**
   *  Topic id
   */
  id: string;

  /**
   *  Topic name
   */
  name: string;

  /**
   *  Resource type(feed/article/video) associated with a topic
   */
  resourceType?: ResourcesType;

  /**
   * Topic type
   */
  type: TopicType;

  /**
   *  Topic icon
   */
  icon?: image.PixelMap;

  /**
   *  Whether the topic is followed by current user
   */
  isFollowed: boolean;

  constructor(topic: Topic) {
    this.id = topic.id;
    this.name = topic.name;
    this.type = topic.type;
    this.resourceType = topic.resourceType;
    this.isFollowed = topic.isFollowed;
  }
}

export enum TopicType {
  FEED = 'feed',
  TOPIC = 'topic',
}