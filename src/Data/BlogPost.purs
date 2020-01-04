module Data.BlogPost where

import Prelude

import Data.Argonaut            (Json
                                ,decodeJson
                                ,encodeJson
                                ,(~>), (~>?)
                                ,(:=), (:=?)
                                ,(.:), (.:?))
import Data.Argonaut.Encode     (class EncodeJson)
import Data.Argonaut.Decode     (class DecodeJson)
import Data.Either              (Either(..))
import Data.Generic.Rep         (class Generic)
import Data.Generic.Rep.Show    (genericShow)
import Data.Maybe               (Maybe(..))
import Data.Newtype             (class Newtype)
import Data.Traversable         (traverse)
import Formless                 as F
import Halogen.Media.Data.Media (MediaRow)

import Data.Image               (Image(..), ImageArray)
import Timestamp                (Timestamp(..)
                                ,defaultTimestamp)

newtype BlogPostId = BlogPostId Int

derive instance newtypeBlogPostId :: Newtype BlogPostId _
derive instance genericBlogPostId :: Generic BlogPostId _
derive instance eqBlogPostId :: Eq BlogPostId
derive instance ordBlogPostId :: Ord BlogPostId

derive newtype instance encodeJsonBlogPostId :: EncodeJson BlogPostId
derive newtype instance decodeJsonBlogPostId :: DecodeJson BlogPostId

instance showBlogPostId :: Show BlogPostId where
  show = genericShow

instance initialBlogPostId :: F.Initial BlogPostId where
  initial = BlogPostId 0

newtype BlogPost = BlogPost
  { id            :: BlogPostId
  , title         :: String
  , content       :: String
  , htmlContent   :: Maybe String
  , featuredImage :: Maybe Image
  , images        :: ImageArray
  , published     :: Boolean
  , publishTime   :: Timestamp
  , isCover       :: Boolean
  , createdAt     :: Timestamp
  , updatedAt     :: Maybe Timestamp
  }

type BlogPostArray = Array BlogPost

derive instance genericBlogPost :: Generic BlogPost _
derive instance eqBlogPost :: Eq BlogPost
derive instance ordBlogPost :: Ord BlogPost

instance showBlogPost :: Show BlogPost where
  show = genericShow

instance decodeJsonBlogPost :: DecodeJson BlogPost where
  decodeJson json = do
    obj           <- decodeJson json
    id            <- obj .:  "id"
    title         <- obj .:  "title"
    content       <- obj .:  "content"
    htmlContent   <- obj .:? "htmlContent"
    featuredImage <- obj .:? "featured_image"
    images        <- obj .:  "images"
    published     <- obj .:  "published"
    publishTime   <- obj .:  "publish_time"
    isCover       <- obj .:  "is_cover"
    createdAt     <- obj .:  "created_at"
    updatedAt     <- obj .:? "updated_at"
    pure $ BlogPost
      { id
      , title
      , content
      , htmlContent
      , featuredImage
      , images
      , published
      , publishTime
      , isCover
      , createdAt
      , updatedAt
      }

instance encodeJsonBlogPost :: EncodeJson BlogPost where
  encodeJson (BlogPost blogPost) 
    =  "title"          := blogPost.title
    ~> "content"        := blogPost.content
    ~> "htmlContent"    := blogPost.htmlContent
    ~> "featured_image" := blogPost.featuredImage
    ~> "images"         := blogPost.images
    ~> "published"      := blogPost.published
    ~> "publish_time"   := blogPost.publishTime
    ~> "is_cover"       := blogPost.isCover
    ~> "created_at"     := blogPost.createdAt
    ~> "updated_at"     := blogPost.updatedAt

decodeBlogPostArray :: Json -> Either String BlogPostArray
decodeBlogPostArray json = decodeJson json >>= traverse decodeJson
