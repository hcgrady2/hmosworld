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

/**
 * Public tool class.
 */
export class CommonUtil {
  /**
   * Replace count with text when the count number exceeds the maximum value.
   * @param count
   * @param max
   * @param replaceText
   */
  public static formatNumToMaxText(count: number, max: number, replaceText: string): string {
    return count > max ? max + replaceText : (count ?? 0).toString();
  }

  /**
   * Replace count with plus sign when the count number over one thousand
   * @param count
   */
  public static transNumberOverOneThousand(count: number): string {
    return CommonUtil.formatNumToMaxText(count, 999, '+');
  }

  /**
   * Replace count with plus sign when the count number over one thousand
   * @param count
   */
  public static transNumberWithUnit(count: number): string {
    if(count < 999) {
      return count.toString();
    }else if(count > 999 && count < 9999) {
      return (count / 1000).toFixed(1) + 'k';
    } else {
      return (count / 10000).toFixed(1) + 'w';
    }
  }

  public static transDistanceWithUnit(distance: number): string {
    if (distance > 1000) {
     return (distance / 1000.00).toFixed(2) + '公里';
    } else {
      return distance.toFixed(2) + '米';
    }
  }
}