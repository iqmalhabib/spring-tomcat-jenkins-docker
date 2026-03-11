<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Health Check 2</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Segoe UI', sans-serif;
            background: #0d1117;
            color: #c9d1d9;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .card {
            background: #161b22;
            border: 1px solid #30363d;
            border-radius: 12px;
            padding: 40px 48px;
            max-width: 480px;
            width: 100%;
            text-align: center;
        }
        .badge {
            display: inline-block;
            padding: 6px 20px;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
            margin-bottom: 24px;
            background: rgba(63,185,80,0.15);
            color: #3fb950;
            border: 1px solid #3fb950;
        }
        h1 { font-size: 1.6rem; color: #e6edf3; margin-bottom: 8px; }
        .version { font-size: 0.8rem; color: #6e7681; margin-bottom: 32px; }
        .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 14px;
            text-align: left;
        }
        .info-item {
            background: #0d1117;
            border: 1px solid #21262d;
            border-radius: 8px;
            padding: 12px 14px;
        }
        .info-label {
            font-size: 0.68rem;
            color: #6e7681;
            text-transform: uppercase;
            margin-bottom: 4px;
        }
        .info-value { font-size: 0.88rem; color: #e6edf3; font-weight: 500; }
        .footer { margin-top: 28px; font-size: 0.72rem; color: #6e7681; }
        .dot {
            width: 10px; height: 10px;
            border-radius: 50%;
            background: #3fb950;
            display: inline-block;
            margin-right: 6px;
            animation: pulse 1.8s infinite;
        }
        @keyframes pulse {
            0%,100% { opacity: 1; }
            50%      { opacity: 0.3; }
        }
    </style>
</head>
<body>
<div class="card">
    <div class="badge">
        <span class="dot"></span> ${status}
    </div>
    <h1>${appName}</h1>
    <p class="version">v${version}</p>
    <div class="info-grid">
        <div class="info-item">
            <div class="info-label">Status</div>
            <div class="info-value">${status}</div>
        </div>
        <div class="info-item">
            <div class="info-label">Version</div>
            <div class="info-value">${version}</div>
        </div>
        <div class="info-item" style="grid-column: span 2;">
            <div class="info-label">Timestamp</div>
            <div class="info-value">${timestamp}</div>
        </div>
    </div>
    <p class="footer">Spring Boot · Embedded Tomcat · JSP</p>
</div>
</body>
</html>
