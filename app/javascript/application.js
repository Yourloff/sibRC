// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import * as ExcelJS from "exceljs";
window.ExcelJS = ExcelJS;

import "./open_excel";
