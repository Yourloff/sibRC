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
        data.forEach((row, rowIndex) => {
            if (!row) return;
            const tr = document.createElement("tr");
            row.forEach((cell, colIndex) => {
                const td = document.createElement("td");
                td.contentEditable = true;
                td.textContent = cell || "";
                td.addEventListener("input", () => {
                    editedData[rowIndex][colIndex] = td.textContent;
                });
                tr.appendChild(td);
            });
            table.appendChild(tr);
        });
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
