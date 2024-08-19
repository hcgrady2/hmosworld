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

import { mediaquery } from '@kit.ArkUI';
import { WindowUtil } from './WindowUtil';

export enum BreakpointTypeEnum {
  SM = 'sm',
  MD = 'md',
  LG = 'lg',
}

export interface BreakpointTypes<T> {
  sm: T;
  md: T;
  lg: T;
}

export class BreakpointType<T> {
  sm: T;
  md: T;
  lg: T;

  constructor(param: BreakpointTypes<T>) {
    this.sm = param.sm;
    this.md = param.md;
    this.lg = param.lg;
  }

  getValue(currentBreakpoint: string): T {
    if (currentBreakpoint === BreakpointTypeEnum.SM) {
      return this.sm;
    }
    if (currentBreakpoint === BreakpointTypeEnum.MD) {
      return this.md;
    }
    return this.lg;
  }
}

export class BreakpointSystem {
  private currentBreakpoint: string = BreakpointTypeEnum.MD;
  private smListener: mediaquery.MediaQueryListener | undefined;
  private mdListener: mediaquery.MediaQueryListener | undefined;
  private lgListener: mediaquery.MediaQueryListener | undefined;

  private updateCurrentBreakpoint(breakpoint: BreakpointTypeEnum) {
    WindowUtil.getDeviceSize(getContext(this));
    if (this.currentBreakpoint !== breakpoint) {
      this.currentBreakpoint = breakpoint;
      AppStorage.set<string>('currentBreakpoint', this.currentBreakpoint);
    }
  }

  private isBreakpointSM = (mediaQueryResult: mediaquery.MediaQueryResult) => {
    if (mediaQueryResult.matches) {
      this.updateCurrentBreakpoint(BreakpointTypeEnum.SM);
    }
  }
  private isBreakpointMD = (mediaQueryResult: mediaquery.MediaQueryResult) => {
    if (mediaQueryResult.matches) {
      this.updateCurrentBreakpoint(BreakpointTypeEnum.MD);
    }
  }
  private isBreakpointLG = (mediaQueryResult: mediaquery.MediaQueryResult) => {
    if (mediaQueryResult.matches) {
      this.updateCurrentBreakpoint(BreakpointTypeEnum.LG);
    }
  }

  public register() {
    this.smListener = mediaquery.matchMediaSync('(320vp<=width<600vp)');
    if (this.smListener?.matches) {
      this.updateCurrentBreakpoint(BreakpointTypeEnum.SM);
    }
    this.smListener?.on('change', this.isBreakpointSM);
    this.mdListener = mediaquery.matchMediaSync('(600vp<=width<840vp)');
    if (this.mdListener?.matches) {
      this.updateCurrentBreakpoint(BreakpointTypeEnum.MD);
    }
    this.mdListener?.on('change', this.isBreakpointMD);
    this.lgListener = mediaquery.matchMediaSync('(840vp<=width)');
    if (this.lgListener?.matches) {
      this.updateCurrentBreakpoint(BreakpointTypeEnum.LG);
    }
    this.lgListener?.on('change', this.isBreakpointLG);
  }

  public unregister() {
    this.smListener?.off('change', this.isBreakpointSM);
    this.mdListener?.off('change', this.isBreakpointMD);
    this.lgListener?.off('change', this.isBreakpointLG);
  }
}