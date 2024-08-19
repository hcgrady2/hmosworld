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

import { BuilderNode, FrameNode, NodeController, Size } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import Logger from './Logger';

let nodeMap: Map<string, MyNodeController | undefined> = new Map();
let controllerMap: Map<string, WebviewController | undefined> = new Map();
let onPageEndMap: Map<string, Function | undefined> = new Map();
let onProgressChangeMap: Map<string, Function | undefined> = new Map();
let onResourceLoadMap: Map<string, Function | undefined> = new Map();
let context: UIContext;
const TAG: string = '[WebUtil]';

class Data {
  public url: string;
  public controller: WebviewController;
  public onPageEndAction?: Function;
  public onProgressChangeAction?: Function;
  public onResourceLoadAction?: Function;

  constructor(url: string, controller: WebviewController) {
    this.url = url;
    this.controller = controller;
  }
}

// Developer-defined template
@Builder
function webBuilder(data: Data) {
  Web({ src: data.url.split('~')[0], controller: data.controller })
    .domStorageAccess(true)
    .zoomAccess(true)
    .fileAccess(true)
    .mixedMode(MixedMode.All)
    .cacheMode(CacheMode.Default)
    .verticalScrollBarAccess(false)
    .javaScriptAccess(true)
    .pinchSmooth(true)
    .onFirstContentfulPaint(() => {
      nodeMap.set('hmos_' + data.url, undefined);
    })
    .onPageEnd(() => {
      onPageEndMap.get(data.url)?.();
    })
    .onProgressChange((event) => {
      Logger.info(TAG, 'newProgress:' + event?.newProgress);
      if (event?.newProgress === 100) {
        onProgressChangeMap.get(data.url)?.();
      }
      Logger.info(TAG, 'onProgressChange weburl: ' + data.url);
    })
    .onResourceLoad((event) => {
      Logger.info(TAG, 'onResourceLoad:' + event?.url);
      onResourceLoadMap.get(data.url)?.(event.url);
    })
    .width('100%')
    .height('100%')
}

let wrap = wrapBuilder<Data[]>(webBuilder);

/**
 * Controls and feeds back the behavior of the node on the corresponding NodeContainer.
 * It must be used together with NodeContainer.
 */
export class MyNodeController extends NodeController {
  private rootNode: BuilderNode<Data[]> | null | undefined = null;
  private isRemove: boolean = false;

  // Used to construct the number of nodes and return the node mount in the corresponding NodeContainer.
  // This API is called when the corresponding NodeContainer is created or by using the rebuild method.
  makeNode(uiContext: UIContext): FrameNode | null {
    Logger.info(TAG, ' uiContext is undifined : ' + (uiContext === undefined));
    if (this.isRemove) {
      return null;
    }
    if (this.rootNode != undefined) {
      return this.rootNode.getFrameNode();
    }
    return null;
  }

  disposeNode() {
    this.rootNode?.dispose();
  }

  aboutToResize(size: Size) {
    Logger.info(TAG, 'aboutToResize width : ' + size.width + ' height : ' + size.height);
  }

  aboutToAppear() {
    if (this.rootNode == undefined) {
      return;
    }
  }

  aboutToDisappear() {
    Logger.info(TAG, 'aboutToDisappear');
  }


  initWeb(url: string, uiContext: UIContext, control: WebviewController, onPageEndAction?: Function) {
    if (this.rootNode != null) {
      return;
    }
    // uiContext is required for creating a node.
    this.rootNode = new BuilderNode(uiContext);
    this.rootNode.dispose()
    // Creating an Offline Component
    this.rootNode.build(wrap, { url: url, controller: control });
  }
}


function createNWeb(url: string, uiContext?: UIContext) {
  if (nodeMap.has(url)) {
    return;
  }
  if (!context && uiContext) {
    context = uiContext;
  }
  let baseNode = new MyNodeController();
  let controller = new webview.WebviewController();
  baseNode.initWeb(url, context, controller);
  // Save the controller of the web page to the map so that the controller can be used when the web page is returned.
  controllerMap.set(url, controller)
  nodeMap.set(url, baseNode);
}

const getNWeb = (url: string): MyNodeController | undefined => {
  return nodeMap.get(url);
}

const getController = (url: string): WebviewController | undefined => {
  return controllerMap.get(url);
}

const setOnPageEndAction = (url: string, onPageEndAction: Function): void => {
  onPageEndMap.set(url, onPageEndAction);
}

const setOnProgressChangeAction = (url: string, onProgressChangeAction: Function): void => {
  onProgressChangeMap.set(url, onProgressChangeAction);
}

const setOnResourceLoadAction = (url: string, onResourceLoadAction: Function): void => {
  onResourceLoadMap.set(url, onResourceLoadAction);
}

// Destruct the created node.
export const deleteNode = (url: string) => {
  let nodeController = nodeMap.get(url);
  nodeController?.disposeNode();
  nodeMap.delete(url);
  controllerMap.delete(url);
  onPageEndMap.delete(url);
}

class WebUrls {
  public static ACTIVITY_URL: string = 'https://developer.huawei.com/home/hdc/hdc2024.html';
  public static CHALLENGE_URL: string = 'https://developer.huawei.com/home/hdc/codelabs?type=subject002';
  public static LEARNING_P001: string =
    'https://developer.huawei.com/consumer/cn/training/course/slightMooc/C101717496599725471';
  public static LEARNING_P002: string =
    'https://developer.huawei.com/consumer/cn/training/course/slightMooc/C101717494752698457';
  public static LEARNING_P003: string =
    'https://developer.huawei.com/consumer/cn/training/course/slightMooc/C101717496870909384';
  public static LEARNING_P004: string =
    'https://developer.huawei.com/consumer/cn/training/course/slightMooc/C101717497122909477';
  public static LEARNING_P005: string =
    'https://developer.huawei.com/consumer/cn/training/course/slightMooc/C101717497398588123';
  public static LEARNING_P006: string =
    'https://developer.huawei.com/consumer/cn/training/course/slightMooc/C101717497640610394';
  public static LEARNING_P007: string =
    'https://developer.huawei.com/consumer/cn/training/course/slightMooc/C101717497918284399';
  public static LEARNING_P008: string =
    'https://developer.huawei.com/consumer/cn/training/course/slightMooc/C101717498132814493';
}

export {
  createNWeb,
  getNWeb,
  WebUrls,
  getController,
  setOnPageEndAction,
  setOnProgressChangeAction,
  setOnResourceLoadAction
};