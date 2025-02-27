// app/javascript/open_excel.js
function initializeExcelEditor() {
    const selectFile = document.querySelector('select[name="act[acceptance_file_id]"]');
    if (!selectFile) {
        console.log("Элемент <select> не найден на странице");
        return;
    }

    // Защита от повторной инициализации
    if (selectFile.dataset.initialized) {
        console.log("Скрипт уже инициализирован для этого элемента");
        return;
    }
    selectFile.dataset.initialized = true;

    const openExcelBtn = document.getElementById("open-excel");
    const excelModal = document.getElementById("excel-modal");
    const closeModalBtn = document.getElementById("close-modal");
    const saveExcelBtn = document.getElementById("save-excel");
    const excelTable = document.getElementById("excel-table");
    const clientId = openExcelBtn.dataset.clientId;

    let workbook;
    let editedData = [];
    let originalSignedId;
    let originalFilename;

    // Функция для обновления состояния кнопки
    function updateOpenButtonState() {
        const hasValue = selectFile.value && selectFile.value.trim() !== "";
        openExcelBtn.disabled = !hasValue;
        console.log("Select value:", selectFile.value, "Button disabled:", openExcelBtn.disabled);
    }

    // Инициализация состояния кнопки
    updateOpenButtonState();

    // Обработчик изменения <select>
    selectFile.addEventListener("change", updateOpenButtonState);

    // Обработчик открытия модального окна
    openExcelBtn.addEventListener("click", async () => {
        originalSignedId = selectFile.value;
        if (!originalSignedId) {
            console.log("Нет выбранного файла для открытия");
            return;
        }

        originalFilename = selectFile.options[selectFile.selectedIndex].text;
        try {
            const response = await fetch(`/clients/${clientId}/acts/download/${originalSignedId}`);
            if (!response.ok) throw new Error("Ошибка загрузки файла");
            const blob = await response.blob();
            const arrayBuffer = await blob.arrayBuffer();

            workbook = new ExcelJS.Workbook();
            await workbook.xlsx.load(arrayBuffer);
            const worksheet = workbook.getWorksheet(1);
            const jsonData = worksheet.getSheetValues();

            editedData = jsonData;
            renderTable(jsonData);
            excelModal.style.display = "flex";
        } catch (error) {
            console.error("Ошибка при загрузке файла:", error);
            alert("Не удалось загрузить Excel файл");
        }
    });

    // Рендеринг таблицы
    function renderTable(data) {
        excelTable.innerHTML = "";
        const table = document.createElement("table");
        let lastLeftCell;
        let lastRightCell;
        let columnCount = 0;

        console.log("Data passed to renderTable:", JSON.stringify(data));

        // Определяем количество столбцов из первого непустого ряда
        if (data && data.length > 0) {
            const firstValidRow = data.find(row => row && Array.isArray(row));
            columnCount = firstValidRow ? firstValidRow.length : 0;
        }

        if (!data || data.length === 0 || columnCount === 0) {
            console.log("No valid data, creating default row");
            const tr = document.createElement("tr");
            const td = document.createElement("td");
            td.contentEditable = true;
            td.textContent = "";
            td.addEventListener("input", () => {
                if (!editedData[0]) editedData[0] = [];
                editedData[0][0] = td.textContent;
            });
            lastLeftCell = td;
            lastRightCell = td;
            tr.appendChild(td);
            table.appendChild(tr);
        } else {
            data.forEach((row, rowIndex) => {
                if (!row || !Array.isArray(row) || row.length === 0) {
                    console.warn(`Row ${rowIndex} is invalid:`, row);
                    return;
                }
                console.log(`Processing row ${rowIndex}:`, row);
                const tr = document.createElement("tr");
                row.forEach((cell, colIndex) => {
                    const td = document.createElement("td");
                    td.contentEditable = true;
                    td.textContent = cell || "";
                    td.addEventListener("input", () => {
                        editedData[rowIndex][colIndex] = td.textContent;
                    });

                    if (rowIndex === data.length - 1) {
                        if (colIndex === 0) {
                            lastLeftCell = td;
                            console.log("Set lastLeftCell:", td);
                        }
                        if (colIndex === row.length - 1) {
                            lastRightCell = td;
                            console.log("Set lastRightCell:", td);
                        }
                    }
                    tr.appendChild(td);
                });
                table.appendChild(tr);
            });

            // Если lastLeftCell не установлен, но строка существует
            if (!lastLeftCell && data.length > 0 && table.lastChild) {
                lastLeftCell = table.lastChild.firstChild;
                console.log("Forced lastLeftCell from last row:", lastLeftCell);
            }
        }

        // Функция для добавления индикатора "+"
        const addIndicator = (cell, position) => {
            if (!cell) {
                console.error(`Cell for ${position} is undefined`);
                return;
            }

            const addRowIndicator = document.createElement("span");
            addRowIndicator.textContent = "+";
            addRowIndicator.className = `add-row-indicator ${position}`;
            addRowIndicator.style.display = "none";
            cell.style.position = "relative";
            cell.appendChild(addRowIndicator);

            console.log(`Indicator added to ${position} cell`, cell);

            cell.addEventListener("mouseenter", () => {
                console.log(`Mouse enter on ${position} cell`);
                addRowIndicator.style.display = "block";
            });
            cell.addEventListener("mouseleave", () => {
                console.log(`Mouse leave on ${position} cell`);
                addRowIndicator.style.display = "none";
            });

            addRowIndicator.addEventListener("click", (e) => {
                e.stopPropagation();
                console.log(`Clicked + on ${position} cell`);
                const newRow = Array(columnCount || 1).fill("");
                editedData.push(newRow);
                renderTable(editedData);
            });
        };

        console.log("Final lastLeftCell:", lastLeftCell);
        console.log("Final lastRightCell:", lastRightCell);
        if (lastLeftCell) {
            addIndicator(lastLeftCell, "left");
        } else {
            console.error("No last left cell found");
        }
        if (lastRightCell && lastRightCell !== lastLeftCell) {
            addIndicator(lastRightCell, "right");
        } else if (!lastRightCell) {
            console.error("No last right cell found");
        }

        excelTable.appendChild(table);
    }

    // Закрытие модального окна
    closeModalBtn.addEventListener("click", () => {
        excelModal.style.display = "none";
    });

    // Сохранение изменений
    saveExcelBtn.addEventListener("click", async () => {
        if (!workbook) {
            alert("Ошибка: сначала откройте файл");
            return;
        }
        const worksheet = workbook.getWorksheet(1);
        if (!worksheet) {
            alert("Ошибка: лист в файле не найден");
            return;
        }
        if (!editedData || editedData.length === 0) {
            alert("Ошибка: нет данных для сохранения");
            return;
        }

        worksheet.spliceRows(1, worksheet.rowCount);
        editedData.forEach((row, rowIndex) => {
            if (row) worksheet.getRow(rowIndex + 1).values = row;
        });

        const buffer = await workbook.xlsx.writeBuffer();
        const blob = new Blob([buffer], { type: "application/octet-stream" });
        const formData = new FormData();
        formData.append("acceptance_file", blob, originalFilename);
        formData.append("signed_id", originalSignedId);

        try {
            saveExcelBtn.disabled = true; // Блокируем кнопку во время сохранения
            const response = await fetch(`/clients/${clientId}/acts/upload_edited`, {
                method: "POST",
                body: formData,
                headers: {
                    "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
                }
            });
            const data = await response.json();
            if (response.ok && data.success) {
                console.log("Файл успешно сохранён:", data);
                alert("Файл успешно обновлён");
                excelModal.style.display = "none";
                // Очистка состояния после сохранения
                workbook = null;
                editedData = [];
            } else {
                throw new Error(data.message || "Ошибка при сохранении");
            }
        } catch (error) {
            console.error("Ошибка при сохранении:", error);
            alert("Произошла ошибка при сохранении");
        } finally {
            saveExcelBtn.disabled = false; // Разблокируем кнопку
        }
    });
}

// Инициализация только один раз при полной загрузке страницы или Turbo-навигации
document.addEventListener("DOMContentLoaded", initializeExcelEditor);
document.addEventListener("turbo:load", initializeExcelEditor);
