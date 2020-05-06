/** @format */

define([
   "dojo/ready",
   "dojo/parser",
   "dojo/has",
   "lsmb/html/credentials_html",
   "lsmb/html/login_html",
   "lsmb/html/payments2_html"
], function (ready, parser) {
   ready(1, function () {
      parser.parse();
   });
   return {};
});
