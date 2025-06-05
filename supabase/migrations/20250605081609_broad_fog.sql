/*
  # Initial Schema Setup for Library Management System

  1. New Tables
    - users
      - id (uuid, primary key)
      - name (text)
      - email (text, unique)
      - password (text)
      - role (text)
      - department (text)
      - phone (text)
      - address (text)
      - created_at (timestamp)

    - books
      - id (uuid, primary key)
      - title (text)
      - author (text)
      - isbn (text, unique)
      - publisher (text)
      - publication_year (integer)
      - category (text)
      - available_quantity (integer)
      - total_quantity (integer)
      - shelf_location (text)
      - description (text)
      - cover_image (text)
      - created_at (timestamp)
      - updated_at (timestamp)

    - ebooks
      - id (uuid, primary key)
      - title (text)
      - author (text)
      - category (text)
      - file_path (text)
      - file_size (text)
      - file_type (text)
      - description (text)
      - uploaded_by (uuid, references users)
      - created_at (timestamp)

    - issued_books
      - id (uuid, primary key)
      - book_id (uuid, references books)
      - user_id (uuid, references users)
      - issue_date (timestamp)
      - return_date (date)
      - actual_return_date (date)
      - status (text)
      - fine_amount (numeric)
      - created_at (timestamp)

    - book_requests
      - id (uuid, primary key)
      - book_id (uuid, references books)
      - user_id (uuid, references users)
      - request_date (timestamp)
      - status (text)
      - notes (text)
      - created_at (timestamp)

    - fines
      - id (uuid, primary key)
      - issued_book_id (uuid, references issued_books)
      - user_id (uuid, references users)
      - amount (numeric)
      - reason (text)
      - status (text)
      - created_at (timestamp)

    - payments
      - id (uuid, primary key)
      - fine_id (uuid, references fines)
      - user_id (uuid, references users)
      - amount (numeric)
      - payment_date (timestamp)
      - payment_method (text)
      - receipt_number (text)
      - created_at (timestamp)

    - notifications
      - id (uuid, primary key)
      - user_id (uuid, references users)
      - message (text)
      - is_read (boolean)
      - created_at (timestamp)

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users
*/

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  email text UNIQUE NOT NULL,
  password text NOT NULL,
  role text NOT NULL CHECK (role IN ('librarian', 'student', 'faculty')),
  department text,
  phone text,
  address text,
  created_at timestamptz DEFAULT now()
);

-- Books table
CREATE TABLE IF NOT EXISTS books (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  title text NOT NULL,
  author text NOT NULL,
  isbn text UNIQUE,
  publisher text,
  publication_year integer,
  category text,
  available_quantity integer NOT NULL DEFAULT 0,
  total_quantity integer NOT NULL DEFAULT 0,
  shelf_location text,
  description text,
  cover_image text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- E-books table
CREATE TABLE IF NOT EXISTS ebooks (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  title text NOT NULL,
  author text NOT NULL,
  category text,
  file_path text NOT NULL,
  file_size text,
  file_type text,
  description text,
  uploaded_by uuid REFERENCES users ON DELETE SET NULL,
  created_at timestamptz DEFAULT now()
);

-- Issued books table
CREATE TABLE IF NOT EXISTS issued_books (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  book_id uuid REFERENCES books ON DELETE CASCADE,
  user_id uuid REFERENCES users ON DELETE CASCADE,
  issue_date timestamptz DEFAULT now(),
  return_date date NOT NULL,
  actual_return_date date,
  status text NOT NULL DEFAULT 'issued' CHECK (status IN ('issued', 'returned', 'overdue')),
  fine_amount numeric(10,2) DEFAULT 0.00,
  created_at timestamptz DEFAULT now()
);

-- Book requests table
CREATE TABLE IF NOT EXISTS book_requests (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  book_id uuid REFERENCES books ON DELETE CASCADE,
  user_id uuid REFERENCES users ON DELETE CASCADE,
  request_date timestamptz DEFAULT now(),
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  notes text,
  created_at timestamptz DEFAULT now()
);

-- Fines table
CREATE TABLE IF NOT EXISTS fines (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  issued_book_id uuid REFERENCES issued_books ON DELETE CASCADE,
  user_id uuid REFERENCES users ON DELETE CASCADE,
  amount numeric(10,2) NOT NULL,
  reason text,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'paid')),
  created_at timestamptz DEFAULT now()
);

-- Payments table
CREATE TABLE IF NOT EXISTS payments (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  fine_id uuid REFERENCES fines ON DELETE CASCADE,
  user_id uuid REFERENCES users ON DELETE CASCADE,
  amount numeric(10,2) NOT NULL,
  payment_date timestamptz DEFAULT now(),
  payment_method text,
  receipt_number text,
  created_at timestamptz DEFAULT now()
);

-- Notifications table
CREATE TABLE IF NOT EXISTS notifications (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid REFERENCES users ON DELETE CASCADE,
  message text NOT NULL,
  is_read boolean NOT NULL DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE books ENABLE ROW LEVEL SECURITY;
ALTER TABLE ebooks ENABLE ROW LEVEL SECURITY;
ALTER TABLE issued_books ENABLE ROW LEVEL SECURITY;
ALTER TABLE book_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE fines ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view their own data" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Librarians can view all users" ON users
  FOR ALL USING (EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'librarian'
  ));

CREATE POLICY "Anyone can view books" ON books
  FOR SELECT USING (true);

CREATE POLICY "Librarians can manage books" ON books
  FOR ALL USING (EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'librarian'
  ));

CREATE POLICY "Users can view their issued books" ON issued_books
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Librarians can manage issued books" ON issued_books
  FOR ALL USING (EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'librarian'
  ));

CREATE POLICY "Users can view their requests" ON book_requests
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Librarians can manage requests" ON book_requests
  FOR ALL USING (EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'librarian'
  ));

CREATE POLICY "Users can view their fines" ON fines
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Librarians can manage fines" ON fines
  FOR ALL USING (EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'librarian'
  ));

CREATE POLICY "Users can view their payments" ON payments
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Librarians can manage payments" ON payments
  FOR ALL USING (EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'librarian'
  ));

CREATE POLICY "Users can view their notifications" ON notifications
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Librarians can manage notifications" ON notifications
  FOR ALL USING (EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'librarian'
  ));

-- Insert default librarian
INSERT INTO users (name, email, password, role)
VALUES (
  'Admin Librarian',
  'admin@library.com',
  crypt('password123', gen_salt('bf')),
  'librarian'
) ON CONFLICT (email) DO NOTHING;