-- =====================================================
-- قاعدة المستخدمين الموحدة - unified_users_2040
-- Unified Users Database
-- =====================================================

CREATE DATABASE IF NOT EXISTS unified_users_2040
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE unified_users_2040;

-- =====================================================
-- 1. جدول المستخدمين (Users)
-- =====================================================
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    department VARCHAR(100),
    employee_id VARCHAR(50) UNIQUE,
    
    -- الصلاحيات الأساسية
    master_role ENUM('super_admin', 'admin', 'technician', 'user', 'viewer') DEFAULT 'user',
    
    -- الحالة
    is_active TINYINT(1) DEFAULT 1,
    last_login DATETIME,
    
    -- التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- للتكامل مع الأنظمة الأخرى
    source_system VARCHAR(50),
    source_id INT,
    migrated_at TIMESTAMP NULL,
    
    -- Indexes
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_employee_id (employee_id),
    INDEX idx_is_active (is_active),
    INDEX idx_master_role (master_role),
    INDEX idx_department (department)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 2. جدول أنواع التذاكر (Ticket Types)
-- =====================================================
CREATE TABLE ticket_types (
    id INT PRIMARY KEY AUTO_INCREMENT,
    type_code VARCHAR(50) UNIQUE NOT NULL,
    type_name_ar VARCHAR(255) NOT NULL,
    type_name_en VARCHAR(255) NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    color VARCHAR(20),
    default_priority ENUM('low','medium','high','emergency') DEFAULT 'medium',
    response_time_hours INT,
    resolution_time_hours INT,
    sort_order INT DEFAULT 0,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_is_active (is_active),
    INDEX idx_sort_order (sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 3. جدول التذاكر المركزي (Central Tickets)
-- =====================================================
CREATE TABLE tickets (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ticket_number VARCHAR(50) UNIQUE NOT NULL,
    ticket_type_id INT NOT NULL,
    category_id INT,
    
    -- المرسل والمستلم
    created_by INT NOT NULL,
    assigned_to INT,
    department_id INT,
    
    -- محتوى التذكرة
    title VARCHAR(255) NOT NULL,
    description TEXT,
    priority ENUM('low','medium','high','emergency') DEFAULT 'medium',
    
    -- حالة التذكرة
    status ENUM('open','under_review','in_progress','waiting_customer',
                'waiting_technical','waiting_parts','waiting_approval',
                'resolved','closed','rejected','cancelled') DEFAULT 'open',
    
    -- معلومات الموقع
    location_building VARCHAR(255),
    location_floor VARCHAR(50),
    location_room VARCHAR(50),
    location_details TEXT,
    
    -- معلومات مقدم الطلب
    requester_name VARCHAR(255),
    requester_phone VARCHAR(50),
    requester_email VARCHAR(255),
    requester_department VARCHAR(255),
    requester_employee_id VARCHAR(50),
    
    -- التواريخ المهمة
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewed_at DATETIME,
    assigned_at DATETIME,
    started_at DATETIME,
    resolved_at DATETIME,
    closed_at DATETIME,
    expected_completion DATE,
    first_response_at DATETIME,
    
    -- الملاحظات والحلول
    work_notes TEXT,
    resolution_notes TEXT,
    materials_used TEXT,
    
    -- التكاليف
    cost_estimate DECIMAL(10,2),
    actual_cost DECIMAL(10,2),
    
    -- تقييم مقدم الطلب
    requester_rating INT,
    requester_feedback TEXT,
    rated_at DATETIME,
    
    -- للتكامل مع الأنظمة الخارجية
    external_system VARCHAR(50),
    external_id INT,
    central_ticket_id INT,  -- للإشارة إلى التذكرة الأصلية
    
    -- إحصائيات
    total_replies INT DEFAULT 0,
    last_reply_at DATETIME,
    last_reply_by INT,
    
    -- معلومات إضافية
    is_urgent TINYINT(1) DEFAULT 0,
    is_private TINYINT(1) DEFAULT 0,
    is_escalated TINYINT(1) DEFAULT 0,
    escalation_reason TEXT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    
    -- التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    source VARCHAR(50),
    
    -- Foreign Keys
    FOREIGN KEY (ticket_type_id) REFERENCES ticket_types(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (assigned_to) REFERENCES users(id),
    
    -- Indexes
    INDEX idx_status (status),
    INDEX idx_priority (priority),
    INDEX idx_created_at (created_at),
    INDEX idx_requester_employee_id (requester_employee_id),
    INDEX idx_central_ticket_id (central_ticket_id),
    INDEX idx_is_urgent (is_urgent),
    INDEX idx_assigned_to (assigned_to)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 4. إدخال بيانات أولية (Sample Data)
-- =====================================================

-- أنواع التذاكر
INSERT INTO ticket_types (type_code, type_name_ar, type_name_en, icon, color) VALUES
('IT_SUPPORT', 'دعم تقني', 'IT Support', 'fa-laptop', '#3498db'),
('IT_NETWORK', 'شبكات', 'Network', 'fa-network-wired', '#2ecc71'),
('IT_SYSTEMS', 'أنظمة وتطوير', 'Systems', 'fa-code', '#9b59b6'),
('CIVIL_MAINT', 'صيانة مدنية', 'Civil Maintenance', 'fa-building', '#e67e22');

-- مستخدم تجريبي (كلمة المرور: admin123 - مشفرة)
INSERT INTO users (username, password, email, full_name, master_role) VALUES
('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin@system.com', 'مدير النظام', 'super_admin');
