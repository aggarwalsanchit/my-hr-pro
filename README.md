# MyHR Pro - Human Resource Management System

[![Laravel](https://img.shields.io/badge/Laravel-12.20.0-red.svg)](https://laravel.com)
[![React](https://img.shields.io/badge/React-18.3.1-blue.svg)](https://reactjs.org)
[![Inertia.js](https://img.shields.io/badge/Inertia.js-2.0.3-purple.svg)](https://inertiajs.com)
[![PHP](https://img.shields.io/badge/PHP-8.2-blue.svg)](https://php.net)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Requirements](#requirements)
- [Installation](#installation)
- [Environment Setup](#environment-setup)
- [Database Configuration](#database-configuration)
- [Running the Application](#running-the-application)
- [Deployment](#deployment)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [License](#license)

---

## 🚀 Overview

**MyHR Pro** is a comprehensive Human Resource Management System built with Laravel 12, React, and Inertia.js. It provides a complete suite of HR tools to manage employees, attendance, leaves, payroll, and more in a modern, responsive interface.

### Key Highlights

- ✅ **Modern Stack**: Laravel 12 + React + Inertia.js
- ✅ **TypeScript**: Fully typed frontend code
- ✅ **Tailwind CSS**: Utility-first styling
- ✅ **Responsive Design**: Works on all devices
- ✅ **Multi-payment Gateway**: Stripe, Razorpay, PayPal, and more
- ✅ **Advanced Features**: Payroll, attendance, leave management
- ✅ **Role-Based Access**: Spatie Permission package
- ✅ **File Management**: Spatie Media Library
- ✅ **API Ready**: RESTful API endpoints

---

## ✨ Features

### Core HR Features

| Feature | Description |
|---------|-------------|
| **Employee Management** | Complete employee profiles, documents, and history |
| **Attendance Tracking** | Check-in/out, attendance reports, overtime calculation |
| **Leave Management** | Leave requests, approvals, balances, and calendars |
| **Payroll Processing** | Salary calculation, tax deductions, payslip generation |
| **Recruitment** | Job postings, applications, candidate management |
| **Performance Reviews** | Goal setting, appraisals, feedback collection |
| **Expense Management** | Expense claims, approvals, reimbursement |
| **Project Management** | Task assignment, progress tracking, timesheets |

### Payment Gateways

| Gateway | Integration | Status |
|---------|-------------|--------|
| **Stripe** | Payment processing | ✅ |
| **Razorpay** | Indian payments | ✅ |
| **PayPal** | International payments | ✅ |
| **Mercado Pago** | Latin America | ✅ |
| **Mollie** | European payments | ✅ |
| **Iyzico** | Turkish payments | ✅ |
| **Cashfree** | Indian payments | ✅ |
| **PayTabs** | Middle East | ✅ |
| **CoinGate** | Cryptocurrency | ✅ |
| **YooKassa** | Russian payments | ✅ |
| **Authorize.net** | US payments | ✅ |
| **FedaPay** | African payments | ✅ |

### Additional Features

- 🔐 **Authentication**: Laravel Breeze with Inertia.js
- 🛡️ **Authorization**: Spatie Laravel Permission
- 📧 **Email Notifications**: Mail notifications and reminders
- 📊 **Reports**: Detailed reports and analytics
- 📁 **File Storage**: AWS S3 compatible storage
- 🔄 **Audit Logs**: Track all user activities
- 📱 **Mobile Responsive**: Works on all screen sizes
- 🌍 **Multi-language**: Translation ready
- 🎨 **Themes**: Light and dark mode support

---

## 🛠️ Technology Stack

### Backend

| Technology | Version | Purpose |
|------------|---------|---------|
| **Laravel** | 12.20.0 | PHP Framework |
| **PHP** | 8.2+ | Programming Language |
| **MySQL** | 8.0+ | Database |
| **Redis** | 7.0+ | Caching & Queue |
| **Laravel Permission** | 6.18 | Role-based access |
| **Laravel Media Library** | 11.13 | File management |
| **Laravel DomPDF** | 3.1 | PDF generation |
| **Laravel Impersonate** | 1.7 | User impersonation |
| **PHPExcel** | 5.5 | Excel import/export |
| **PHPWord** | 1.4 | Word document generation |

### Frontend

| Technology | Version | Purpose |
|------------|---------|---------|
| **React** | 18.3.1 | UI Framework |
| **Inertia.js** | 2.0.3 | Full-stack SPA |
| **TypeScript** | 5.4+ | Type-safe JavaScript |
| **Tailwind CSS** | 3.4+ | Styling |
| **Vite** | 6.4.1 | Build tool |
| **Ziggy** | 2.4 | Laravel routes in JS |

### DevOps

| Technology | Purpose |
|------------|---------|
| **Docker** | Containerization |
| **Render** | Hosting & Deployment |
| **Aiven** | MySQL Database |
| **GitHub** | Version control |
| **AWS S3** | File storage |

---

## 📋 Requirements

### System Requirements

- **PHP**: 8.2 or higher
- **MySQL**: 8.0 or higher
- **Node.js**: 20.x or higher
- **Composer**: Latest version
- **NPM**: Latest version

### PHP Extensions

```bash
# Required extensions
- bcmath
- ctype
- fileinfo
- gd
- json
- mbstring
- mysqli
- openssl
- pdo
- pdo_mysql
- tokenizer
- xml
- zip