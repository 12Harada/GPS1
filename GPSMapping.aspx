<%@ Page Language="C#" Inherits="Microsoft.SharePoint.WebPartPages.WebPartPage,Microsoft.SharePoint,Version=16.0.0.0,Culture=neutral,PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Import Namespace="Microsoft.SharePoint" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>GPS位置情報マッピング</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <SharePoint:CssRegistration Name="corev15.css" runat="server" />
    <style type="text/css">
        body {
            font-family: "Segoe UI", Tahoma, Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .ms-webpart-chrome-title {
            background-color: #0078d4;
            color: white;
            padding: 10px;
            font-weight: bold;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background-color: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .controls {
            margin-bottom: 20px;
            padding: 20px;
            background-color: #f8f9fa;
            border-radius: 8px;
            border: 1px solid #dee2e6;
        }
        .file-input {
            margin-bottom: 10px;
        }
        .info {
            margin-top: 10px;
            padding: 10px;
            background-color: #e8f4f8;
            border-radius: 4px;
            display: none;
        }
        #map {
            height: 600px;
            width: 100%;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            border: 1px solid #dee2e6;
        }
        .error {
            color: #d32f2f;
            background-color: #ffebee;
            padding: 10px;
            border-radius: 4px;
            margin-top: 10px;
            border: 1px solid #ffcdd2;
        }
        .success {
            color: #388e3c;
            background-color: #e8f5e8;
            padding: 10px;
            border-radius: 4px;
            margin-top: 10px;
            border: 1px solid #c8e6c9;
        }
        .custom-div-icon {
            background: white;
            border: 2px solid #333;
            border-radius: 50%;
            text-align: center;
            line-height: 30px;
            font-weight: bold;
            font-size: 12px;
            color: white;
        }
        .search-container {
            margin-top: 15px;
            padding: 15px;
            background-color: #f0f8ff;
            border-radius: 6px;
            border: 1px solid #0078d4;
        }
        .search-row {
            display: flex;
            gap: 15px;
            align-items: center;
            margin-bottom: 10px;
            flex-wrap: wrap;
        }
        .search-input {
            padding: 8px;
            border: 1px solid #0078d4;
            border-radius: 4px;
            font-size: 14px;
            min-width: 200px;
        }
        .search-button {
            padding: 8px 16px;
            background-color: #0078d4;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            transition: background-color 0.2s;
        }
        .search-button:hover {
            background-color: #106ebe;
        }
        .clear-button {
            padding: 8px 16px;
            background-color: #6b7280;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            transition: background-color 0.2s;
        }
        .clear-button:hover {
            background-color: #4b5563;
        }
        .search-result {
            margin-top: 10px;
            font-size: 12px;
            color: #666;
            padding: 8px;
            background-color: white;
            border-radius: 4px;
        }
        .highlight-marker {
            border: 3px solid #ff6b35 !important;
            box-shadow: 0 0 10px rgba(255, 107, 53, 0.5);
        }
        .file-upload-area {
            border: 2px dashed #0078d4;
            border-radius: 8px;
            padding: 20px;
            text-align: center;
            background-color: #fafafa;
        }
        .file-upload-area:hover {
            background-color: #f0f8ff;
        }
        h1 {
            color: #323130;
            font-size: 24px;
            margin-bottom: 20px;
        }
        h3 {
            color: #323130;
            font-size: 16px;
            margin-bottom: 15px;
        }
        label {
            font-weight: 600;
            color: #323130;
        }
        .format-info {
            margin-top: 10px;
            font-size: 12px;
            color: #605e5c;
            font-style: italic;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <SharePoint:ScriptLink Name="sp.js" runat="server" OnDemand="true" LoadAfterUI="true" Localizable="false" />
        
        <div class="container">
            <h1>GPS位置情報マッピング</h1>
            
            <div class="controls">
                <div class="file-input">
                    <div class="file-upload-area">
                        <label for="csvFile">📁 CSVファイルを選択してください:</label><br />
                        <input type="file" id="csvFile" accept=".csv" style="margin-top: 10px;" />
                        <div class="format-info">
                            形式: 7桁ID（数字のみ、または最初がアルファベット＋6桁数字）,緯度,経度,GPS取得年月日時分(YYYYMMDDhhmm)
                        </div>
                    </div>
                </div>
                <div class="info" id="fileInfo"></div>
                <div id="message"></div>
                
                <div class="search-container" id="searchContainer" style="display: none;">
                    <h3>🔍 検索機能</h3>
                    <div class="search-row">
                        <label for="searchId">7桁ID:</label>
                        <input type="text" id="searchId" class="search-input" placeholder="1234567 または A123456" maxlength="7" />
                        <button type="button" onclick="searchById()" class="search-button">ID検索</button>
                    </div>
                    <div class="search-row">
                        <label for="searchDate">取得日:</label>
                        <input type="text" id="searchDate" class="search-input" placeholder="20240115 (YYYYMMDD)" maxlength="8" />
                        <button type="button" onclick="searchByDate()" class="search-button">日付検索</button>
                        <button type="button" onclick="clearSearch()" class="clear-button">検索解除</button>
                    </div>
                    <div class="search-result" id="searchResult"></div>
                </div>
            </div>
            
            <div id="map"></div>
        </div>
    </form>

    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" type="text/javascript"></script>
    <script type="text/javascript">
        var map;
        var markers = [];
        var pathLine = null;
        var allData = [];
        var highlightedMarkers = [];

        function initMap() {
            map = L.map('map').setView([35.6762, 139.6503], 10);
            
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '© OpenStreetMap contributors'
            }).addTo(map);
        }

        function clearMarkers() {
            markers.forEach(function(marker) {
                map.removeLayer(marker);
            });
            markers = [];
            if (pathLine) {
                map.removeLayer(pathLine);
                pathLine = null;
            }
        }

        function getColorByIndex(index, total) {
            var hue = (index / Math.max(total - 1, 1)) * 240;
            return 'hsl(' + (240 - hue) + ', 70%, 50%)';
        }

        function parseCSVLine(line) {
            var result = [];
            var current = '';
            var inQuotes = false;
            
            for (var i = 0; i < line.length; i++) {
                var char = line.charAt(i);
                
                if (char === '"') {
                    inQuotes = !inQuotes;
                } else if (char === ',' && !inQuotes) {
                    result.push(current.trim());
                    current = '';
                } else {
                    current += char;
                }
            }
            result.push(current.trim());
            return result;
        }

        function parseTimestamp(timestampStr) {
            if (!/^\d{12}$/.test(timestampStr)) {
                throw new Error('日時は12桁の数字 (YYYYMMDDhhmm) である必要があります: ' + timestampStr);
            }
            
            var year = timestampStr.substring(0, 4);
            var month = timestampStr.substring(4, 6);
            var day = timestampStr.substring(6, 8);
            var hour = timestampStr.substring(8, 10);
            var minute = timestampStr.substring(10, 12);
            
            var date = new Date(year, month - 1, day, hour, minute);
            var formatted = year + '年' + month + '月' + day + '日 ' + hour + ':' + minute;
            
            return { date: date, formatted: formatted };
        }

        function parseCSV(csvText) {
            var lines = csvText.trim().split('\n');
            var data = [];
            
            for (var i = 0; i < lines.length; i++) {
                var line = lines[i].trim();
                if (!line) continue;
                
                var columns = parseCSVLine(line);
                if (columns.length < 4) {
                    throw new Error('行 ' + (i + 1) + ': 列数が不足しています (必要: 4列, 実際: ' + columns.length + '列)');
                }
                
                var id = columns[0].replace(/"/g, '').trim();
                var latStr = columns[1].replace(/"/g, '').trim();
                var lngStr = columns[2].replace(/"/g, '').trim();
                var timestampStr = columns[3].replace(/"/g, '').trim();
                
                if (!/^[A-Za-z]\d{6}$|^\d{7}$/.test(id)) {
                    throw new Error('行 ' + (i + 1) + ': ID "' + id + '" は7桁（数字のみ）または7文字（最初がアルファベット＋6桁数字）である必要があります');
                }
                
                var lat = parseFloat(latStr);
                var lng = parseFloat(lngStr);
                
                if (isNaN(lat)) {
                    throw new Error('行 ' + (i + 1) + ': 緯度 "' + latStr + '" が数値ではありません');
                }
                if (isNaN(lng)) {
                    throw new Error('行 ' + (i + 1) + ': 経度 "' + lngStr + '" が数値ではありません');
                }
                
                if (lat < -90 || lat > 90) {
                    throw new Error('行 ' + (i + 1) + ': 緯度 ' + lat + ' が有効範囲外です (-90〜90)');
                }
                if (lng < -180 || lng > 180) {
                    throw new Error('行 ' + (i + 1) + ': 経度 ' + lng + ' が有効範囲外です (-180〜180)');
                }
                
                try {
                    var timestampInfo = parseTimestamp(timestampStr);
                    data.push({ 
                        id: id, 
                        timestamp: timestampInfo.date, 
                        timestampFormatted: timestampInfo.formatted,
                        lat: lat, 
                        lng: lng 
                    });
                } catch (error) {
                    throw new Error('行 ' + (i + 1) + ': ' + error.message);
                }
            }
            
            return data;
        }

        function loadCSVData(data) {
            if (data.length === 0) {
                showMessage('データが見つかりませんでした', 'error');
                return;
            }
            
            allData = data.slice();
            allData.sort(function(a, b) {
                return a.timestamp - b.timestamp;
            });
            
            showMessage('✅ ' + data.length + '件のCSVデータを読み込みました。検索してください。', 'success');
            showFileInfo('読み込み完了: ' + data.length + '件のデータ（検索可能）');
            
            document.getElementById('searchContainer').style.display = 'block';
        }

        function displayDataOnMap(data) {
            clearMarkers();
            
            if (data.length === 0) {
                showMessage('表示するデータがありません', 'error');
                return;
            }
            
            if (data.length > 200) {
                showMessage('⚠️ 検索結果が200件を超えています（' + data.length + '件）。条件を絞り込んで再検索してください。', 'error');
                document.getElementById('searchResult').textContent = '検索結果が多すぎます。条件を絞り込んでください（' + data.length + '件）';
                return;
            }
            
            data.sort(function(a, b) {
                return a.timestamp - b.timestamp;
            });
            
            var bounds = L.latLngBounds();
            var pathCoordinates = [];
            
            data.forEach(function(point, index) {
                var orderNumber = index + 1;
                var color = getColorByIndex(index, data.length);
                
                var customIcon = L.divIcon({
                    html: '<div class="custom-div-icon" style="background-color: ' + color + ';">' + orderNumber + '</div>',
                    iconSize: [30, 30],
                    iconAnchor: [15, 15],
                    popupAnchor: [0, -15],
                    className: 'custom-marker'
                });
                
                var marker = L.marker([point.lat, point.lng], { icon: customIcon })
                    .addTo(map)
                    .bindPopup(
                        '<strong>順序:</strong> ' + orderNumber + '番目<br/>' +
                        '<strong>ID:</strong> ' + point.id + '<br/>' +
                        '<strong>GPS取得時刻:</strong> ' + point.timestampFormatted + '<br/>' +
                        '<strong>位置:</strong> ' + point.lat.toFixed(6) + ', ' + point.lng.toFixed(6)
                    );
                
                marker._pointData = point;
                markers.push(marker);
                bounds.extend([point.lat, point.lng]);
                pathCoordinates.push([point.lat, point.lng]);
            });
            
            if (pathCoordinates.length > 1) {
                pathLine = L.polyline(pathCoordinates, {
                    color: '#0078d4',
                    weight: 3,
                    opacity: 0.7,
                    dashArray: '5, 10'
                }).addTo(map);
            }
            
            if (data.length > 0) {
                map.fitBounds(bounds, { padding: [20, 20] });
            }
        }

        function showMessage(message, type) {
            type = type || 'info';
            var messageDiv = document.getElementById('message');
            messageDiv.innerHTML = message;
            messageDiv.className = type;
            messageDiv.style.display = 'block';
        }

        function showFileInfo(info) {
            var infoDiv = document.getElementById('fileInfo');
            infoDiv.textContent = info;
            infoDiv.style.display = 'block';
        }

        function handleFileSelect(event) {
            var file = event.target.files[0];
            if (!file) return;
            
            showFileInfo('📄 ファイル読み込み中: ' + file.name);
            
            var reader = new FileReader();
            reader.onload = function(e) {
                try {
                    var csvText = e.target.result;
                    var data = parseCSV(csvText);
                    loadCSVData(data);
                } catch (error) {
                    showMessage('❌ エラー: ' + error.message, 'error');
                    document.getElementById('fileInfo').style.display = 'none';
                }
            };
            
            reader.onerror = function() {
                showMessage('❌ ファイルの読み込みに失敗しました', 'error');
                document.getElementById('fileInfo').style.display = 'none';
            };
            
            reader.readAsText(file, 'UTF-8');
        }

        function clearHighlight() {
            highlightedMarkers.forEach(function(marker) {
                var element = marker.getElement();
                if (element) {
                    element.classList.remove('highlight-marker');
                }
            });
            highlightedMarkers = [];
        }

        function highlightMarkers(matchedData) {
            clearHighlight();
            
            markers.forEach(function(marker) {
                var pointData = marker._pointData;
                var isMatched = matchedData.some(function(data) {
                    return data.id === pointData.id && 
                           data.timestamp.getTime() === pointData.timestamp.getTime();
                });
                
                if (isMatched) {
                    var element = marker.getElement();
                    if (element) {
                        element.classList.add('highlight-marker');
                        highlightedMarkers.push(marker);
                    }
                }
            });
        }

        function searchById() {
            var searchId = document.getElementById('searchId').value.trim();
            var resultDiv = document.getElementById('searchResult');
            
            if (!searchId) {
                resultDiv.textContent = 'IDを入力してください';
                return;
            }
            
            if (!/^[A-Za-z]\d{6}$|^\d{7}$/.test(searchId)) {
                resultDiv.textContent = '7桁の数字、または最初がアルファベット＋6桁数字を入力してください';
                return;
            }
            
            var matchedData = allData.filter(function(point) {
                return point.id === searchId;
            });
            
            if (matchedData.length === 0) {
                resultDiv.textContent = '❌ ID "' + searchId + '" が見つかりませんでした';
                clearMarkers();
            } else if (matchedData.length > 200) {
                resultDiv.textContent = '⚠️ ID "' + searchId + '" の検索結果が200件を超えています（' + matchedData.length + '件）。条件を絞り込んでください';
                clearMarkers();
            } else {
                resultDiv.textContent = '✅ ID "' + searchId + '" で ' + matchedData.length + ' 件見つかりました';
                displayDataOnMap(matchedData);
                
                if (matchedData.length === 1) {
                    map.setView([matchedData[0].lat, matchedData[0].lng], 15);
                }
            }
        }

        function searchByDate() {
            var searchDate = document.getElementById('searchDate').value.trim();
            var resultDiv = document.getElementById('searchResult');
            
            if (!searchDate) {
                resultDiv.textContent = '日付を入力してください';
                return;
            }
            
            if (!/^\d{8}$/.test(searchDate)) {
                resultDiv.textContent = 'YYYYMMDD形式で入力してください（例: 20240115）';
                return;
            }
            
            var matchedData = allData.filter(function(point) {
                var timestampStr = point.timestamp.getFullYear().toString() +
                    ('0' + (point.timestamp.getMonth() + 1)).slice(-2) +
                    ('0' + point.timestamp.getDate()).slice(-2);
                return timestampStr === searchDate;
            });
            
            if (matchedData.length === 0) {
                resultDiv.textContent = '❌ 日付 "' + searchDate + '" のデータが見つかりませんでした';
                clearMarkers();
            } else if (matchedData.length > 200) {
                resultDiv.textContent = '⚠️ 日付 "' + searchDate + '" の検索結果が200件を超えています（' + matchedData.length + '件）。条件を絞り込んでください';
                clearMarkers();
            } else {
                resultDiv.textContent = '✅ 日付 "' + searchDate + '" で ' + matchedData.length + ' 件見つかりました';
                displayDataOnMap(matchedData);
                
                if (matchedData.length > 0) {
                    var bounds = L.latLngBounds();
                    matchedData.forEach(function(point) {
                        bounds.extend([point.lat, point.lng]);
                    });
                    map.fitBounds(bounds, { padding: [20, 20] });
                }
            }
        }

        function clearSearch() {
            document.getElementById('searchId').value = '';
            document.getElementById('searchDate').value = '';
            document.getElementById('searchResult').textContent = '';
            clearMarkers();
        }

        // SharePoint対応の初期化
        function initializePage() {
            initMap();
            document.getElementById('csvFile').addEventListener('change', handleFileSelect);
            
            document.getElementById('searchId').addEventListener('keypress', function(e) {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    searchById();
                }
            });
            
            document.getElementById('searchDate').addEventListener('keypress', function(e) {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    searchByDate();
                }
            });
        }

        // SharePoint環境での初期化
        if (typeof _spPageContextInfo !== 'undefined') {
            // SharePoint環境
            ExecuteOrDelayUntilScriptLoaded(initializePage, "sp.js");
        } else {
            // 通常のブラウザ環境
            document.addEventListener('DOMContentLoaded', initializePage);
        }
    </script>
</body>
</html>