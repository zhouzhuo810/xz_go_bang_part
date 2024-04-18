const app = {};
globalThis.getApp = () => {
  return app;
};

const { Main } = require("./pages/index/index");

const canvas = wx.createCanvas({});
const main = new Main(canvas);
main.run();

//wx.getGameServerManager().login().then((data) => {
//  wx.getGameServerManager().onRoomInfoChange((callback) => {
//    if (callback.res) {
//      console.log(callback.res);
//    }
//  });
//});

