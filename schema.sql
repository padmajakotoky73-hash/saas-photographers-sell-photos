Here's the Supabase SQL schema for a photographer SaaS platform:

```sql
-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Users table (extends auth.users)
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  auth_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT UNIQUE NOT NULL,
  display_name TEXT,
  bio TEXT,
  avatar_url TEXT,
  website_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- RLS policies for users
CREATE POLICY "Users can view their own profile" 
ON users FOR SELECT USING (auth_id = auth.uid());

CREATE POLICY "Users can update their own profile"
ON users FOR UPDATE USING (auth_id = auth.uid());

-- Albums table
CREATE TABLE IF NOT EXISTS albums (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  cover_photo_url TEXT,
  price DECIMAL(10,2),
  is_public BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable RLS for albums
ALTER TABLE albums ENABLE ROW LEVEL SECURITY;

-- RLS policies for albums
CREATE POLICY "Users can manage their own albums"
ON albums FOR ALL USING (user_id = (SELECT id FROM users WHERE auth_id = auth.uid()));

CREATE POLICY "Public albums are viewable"
ON albums FOR SELECT USING (is_public = TRUE);

-- Photos table
CREATE TABLE IF NOT EXISTS photos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  album_id UUID NOT NULL REFERENCES albums(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title TEXT,
  description TEXT,
  image_url TEXT NOT NULL,
  original_filename TEXT,
  width INTEGER,
  height INTEGER,
  file_size BIGINT,
  price DECIMAL(10,2),
  is_public BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable RLS for photos
ALTER TABLE photos ENABLE ROW LEVEL SECURITY;

-- RLS policies for photos
CREATE POLICY "Users can manage their own photos"
ON photos FOR ALL USING (user_id = (SELECT id FROM users WHERE auth_id = auth.uid()));

CREATE POLICY "Public photos are viewable"
ON photos FOR SELECT USING (is_public = TRUE);

-- Purchases table
CREATE TABLE IF NOT EXISTS purchases (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  buyer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  seller_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  photo_id UUID REFERENCES photos(id) ON DELETE SET NULL,
  album_id UUID REFERENCES albums(id) ON DELETE SET NULL,
  amount DECIMAL(10,2) NOT NULL,
  transaction_fee DECIMAL(10,2) NOT NULL,
  currency TEXT NOT NULL DEFAULT 'USD',
  status TEXT NOT NULL DEFAULT 'completed',
  payment_intent_id TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable RLS for purchases
ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;

-- RLS policies for purchases
CREATE POLICY "Buyers can view their purchases"
ON purchases FOR SELECT USING (buyer_id = (SELECT id FROM users WHERE auth_id = auth.uid()));

CREATE POLICY "Sellers can view their sales"
ON purchases FOR SELECT USING (seller_id = (SELECT id FROM users WHERE auth_id = auth.uid()));

-- Tags table
CREATE TABLE IF NOT EXISTS tags (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Photo-Tag junction table
CREATE TABLE IF NOT EXISTS photo_tags (
  photo_id UUID NOT NULL REFERENCES photos(id) ON DELETE CASCADE,
  tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
  PRIMARY KEY (photo_id, tag_id)
);

-- Enable RLS for photo_tags
ALTER TABLE photo_tags ENABLE ROW LEVEL SECURITY;

-- RLS policies for photo_tags
CREATE POLICY "Photo tags are visible with photo access"
ON photo_tags FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM photos 
    WHERE photos.id = photo_tags.photo_id 
    AND (photos.is_public OR photos.user_id = (SELECT id FROM users WHERE auth_id = auth.uid()))
  )
);

-- Create indexes
CREATE INDEX idx_albums_user_id ON albums(user_id);
CREATE INDEX idx_photos_album_id ON photos(album_id);
CREATE INDEX idx_photos_user_id ON photos(user_id);
CREATE INDEX idx_purchases_buyer_id ON purchases(buyer_id);
CREATE INDEX idx_purchases_seller_id ON purchases(seller_id);
CREATE INDEX idx_photo_tags_photo_id ON photo_tags(photo_id);
CREATE INDEX idx_photo_tags_tag_id ON photo_tags(tag_id);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply triggers to tables with updated_at
CREATE TRIGGER update_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_albums_updated_at
BEFORE UPDATE ON albums
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_photos_updated_at
BEFORE UPDATE ON photos
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```