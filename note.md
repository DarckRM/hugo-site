### 一些学习心得

- 关于Vite，VUE3 以及封装后的Axios所遇到的跨域问题
  - 封装的axios里不要再配置`default.baseURL`，会导致`config.vite.js`里配置的`proxy`失效