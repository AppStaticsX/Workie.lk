# Live Updates Implementation for Post Likes and Comments

## Overview
This implementation provides real-time updates for post likes and comments using Socket.IO. When a user likes or comments on a post, the changes are immediately reflected across all connected clients without requiring a page refresh.

## Architecture

### Backend (Node.js + Socket.IO)
- **Socket Service**: Located in `backend/services/socketService.js`
- **Socket Events**: Integrated into `backend/routes/posts.js`
- **Events Emitted**:
  - `post_like_updated`: When a post is liked/unliked
  - `post_comment_added`: When a new comment is added
  - `post_like_notification`: Personal notification for post owner
  - `post_comment_notification`: Personal notification for post owner

### Frontend (Flutter + Socket.IO Client)
- **Socket Service**: `lib/services/socket_service.dart`
- **Integration Points**: 
  - HomePage: Listens for feed updates
  - PostCardModel: Listens for individual post updates
  - main.dart: Initializes socket service globally

## How It Works

### 1. Like Updates
When a user likes/unlikes a post:

**Backend Flow:**
1. User hits like endpoint: `POST /api/posts/:postId/like`
2. Backend updates database
3. Backend emits `post_like_updated` event to all connected clients
4. Backend emits `post_like_notification` to post owner (if different user)

**Frontend Flow:**
1. User taps like button
2. Local UI updates optimistically (immediate feedback)
3. API call is made to backend
4. Socket receives `post_like_updated` event
5. All PostCardModels listening for this post update their like counts
6. HomePage updates the post in its feed array

### 2. Comment Updates
When a user adds a comment:

**Backend Flow:**
1. User submits comment: `POST /api/posts/:postId/comments`
2. Backend adds comment to database
3. Backend emits `post_comment_added` event to all clients
4. Backend emits `post_comment_notification` to post owner (if different user)

**Frontend Flow:**
1. User submits comment via CommentBottomSheet
2. Local comment list updates (optimistic)
3. API call is made to backend
4. Socket receives `post_comment_added` event
5. All PostCardModels update their comment counts
6. HomePage updates the post in its feed array

### 3. New Post Creation
When a user creates a new post:

**Backend Flow:**
1. User creates post: `POST /api/posts`
2. Backend saves post to database
3. Backend emits `new_post_created` event to all connected clients

**Frontend Flow:**
1. User creates post via create post screen
2. Socket receives `new_post_created` event
3. HomePage formats the new post and adds it to the top of the feed
4. All users see the new post appear in their feeds immediately

### 4. Post Updates/Edits
When a user edits a post:

**Backend Flow:**
1. User updates post: `PUT /api/posts/:postId`
2. Backend updates post in database
3. Backend emits `post_updated` event to all connected clients

**Frontend Flow:**
1. User edits post content
2. Socket receives `post_updated` event
3. HomePage and PostCardModels update with new content
4. All users see the updated post content immediately

### 5. Post Deletion
When a user deletes a post:

**Backend Flow:**
1. User deletes post: `DELETE /api/posts/:postId`
2. Backend removes post from database
3. Backend emits `post_deleted` event to all connected clients

**Frontend Flow:**
1. User deletes post
2. Socket receives `post_deleted` event
3. HomePage removes the post from the feed
4. Post disappears from all users' feeds immediately

## Key Features

### Real-time Synchronization
- Changes appear instantly across all connected devices
- No manual refresh needed
- Optimistic updates for smooth UX

### Smart Event Handling
- Each PostCardModel only responds to events for its specific post
- HomePage updates the feed data structure
- Proper cleanup of event listeners on widget disposal

### Connection Management
- Automatic reconnection on network issues
- User authentication on connection
- Graceful handling of connection errors

## Socket Events Reference

### Emitted by Backend:
```javascript
// Like update for all users
{
  event: 'post_like_updated',
  data: {
    postId: 'post_id',
    isLiked: true/false,
    likesCount: 42,
    likes: [...],
    userId: 'user_who_liked'
  }
}

// Comment update for all users
{
  event: 'post_comment_added',
  data: {
    postId: 'post_id',
    comment: { /* comment object */ },
    totalComments: 15,
    commenterUserId: 'user_who_commented'
  }
}

// New post created
{
  event: 'new_post_created',
  data: {
    postId: 'new_post_id',
    post: { /* full post object */ },
    creatorUserId: 'user_who_created',
    creatorName: 'John Doe'
  }
}

// Post updated/edited
{
  event: 'post_updated',
  data: {
    postId: 'post_id',
    updatedPost: { /* updated post object */ },
    updatedBy: 'user_who_updated',
    updatedByName: 'Jane Smith',
    changes: ['content', 'media'] // fields that were changed
  }
}

// Post deleted
{
  event: 'post_deleted',
  data: {
    postId: 'deleted_post_id',
    deletedBy: 'user_who_deleted',
    deletedByName: 'John Doe'
  }
}
```

### Listened by Frontend:
- Flutter widgets automatically subscribe to relevant events
- Events are filtered by postId to ensure updates go to correct posts
- UI updates are performed in setState() for proper rendering

## Usage

### For Developers

1. **Adding New Real-time Features:**
   - Add socket emit in backend route
   - Add socket listener in Flutter widget
   - Handle the event data and update UI state

2. **Debugging:**
   - Check browser console for socket connection logs
   - Verify events are being emitted in backend logs
   - Ensure Flutter widgets are properly subscribing/unsubscribing

### Installation Requirements

**Backend Dependencies:**
- Already included in existing setup
- socket.io (installed)
- Express server with HTTP server wrapper

**Frontend Dependencies:**
```yaml
dependencies:
  socket_io_client: ^3.1.1  # Added to pubspec.yaml
```

## Configuration

### Backend Socket Server
The socket server is configured in `server.js`:
```javascript
const io = new Server(server, {
  cors: {
    origin: process.env.CLIENT_URL || "http://localhost:5173",
    credentials: true,
    methods: ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"]
  }
});
```

### Frontend Socket Client
The socket client connects to:
```dart
const String baseUrl = 'https://workie-lk-backend.onrender.com';
```

## Testing the Implementation

1. **Multi-device Testing:**
   - Open app on multiple devices/emulators
   - Like a post on one device
   - Verify like count updates on other devices within 1-2 seconds

2. **Comment Testing:**
   - Add a comment on one device
   - Check that comment appears on other devices
   - Verify comment counts are updated

3. **New Post Testing:**
   - Create a new post on one device
   - Verify the post appears at the top of feeds on other devices
   - Check that the post formatting and media display correctly

4. **Post Edit Testing:**
   - Edit post content on one device
   - Verify updated content appears on other devices
   - Check that edited posts show updated timestamps

5. **Post Delete Testing:**
   - Delete a post on one device
   - Verify the post disappears from feeds on other devices
   - Ensure no orphaned references remain

6. **Connection Testing:**
   - Disable network on one device
   - Perform actions on other devices
   - Re-enable network and verify updates sync

## Performance Considerations

- Socket connections are maintained efficiently with proper cleanup
- Events are only processed for relevant posts (filtered by postId)
- Optimistic updates prevent UI lag
- Automatic reconnection prevents permanent disconnections

## Future Enhancements

Possible additions to this system:
1. Real-time new post notifications
2. Live typing indicators for comments
3. Real-time user presence (online/offline status)
4. Live reaction animations
5. Push notifications integration with socket events