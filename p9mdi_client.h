#pragma once

enum ConnectionStatusEnum
{
	ConnectionStatusEnum_Connected,
	ConnectionStatusEnum_Disconnected
};

enum SubscriptionType
{
	SnapshotOnly,
	SnapshotPlusIncremental,
	IncrementalOnly
};

#define BOOK_SIDE_BUY		1
#define BOOK_SIDE_SELL		2

struct KEY_AND_VALUE
{
	const char* key;
	const char* value;	
};

#define P9MDI_EVENT_SET					0x14
#define P9MDI_EVENT_INSERT				0x15
#define P9MDI_EVENT_DELETE				0x16
#define P9MDI_EVENT_PUSH_BACK			0x17
#define P9MDI_EVENT_PUSH_FRONT			0x18
#define P9MDI_EVENT_POP_BACK			0x19
#define P9MDI_EVENT_POP_FRONT			0x1A
#define P9MDI_EVENT_CLEAR				0x1B

#define P9_FAILED(x) (x<0)

typedef void (*FieldChangeCallback)(void* /*cookie*/, unsigned /*eventCode*/, const char* /*key*/, const char* /*value*/ );
typedef void (*ListChangeCallback)(void* /*cookie*/, unsigned /*eventCode*/, unsigned /*position*/, struct KEY_AND_VALUE* /*fields*/);
typedef void (*MapChangeCallback)(void* /*cookie*/, unsigned /*eventCode*/, const char* /*key*/, struct KEY_AND_VALUE* /*fields*/);


struct P9MDI_CONNECTION;

const char* p9mdi_get_field_value(struct KEY_AND_VALUE* field_array, const char* key);
const char* p9mdi_get_event_code_name(unsigned int event_code);

int p9mdi_connect(const char* server, unsigned short port, const char* username, const char* password, struct P9MDI_CONNECTION** connection);
int	p9mdi_disconnect(struct P9MDI_CONNECTION* connection);

// use it if you need the socket fd to async io (select)
int p9mdi_get_connection_fd(struct P9MDI_CONNECTION* connection);

int p9mdi_subscribe_security_list(
	struct P9MDI_CONNECTION* connection,
	const char* exchange,	
	enum SubscriptionType subscriptionType,
	MapChangeCallback map_change_callback, 
	void* cookie, 
	void** subscription_handle);

int p9mdi_subscribe_instrument_order_book(
	struct P9MDI_CONNECTION* connection,
	const char* exchange,
	const char* symbol,
	unsigned int side,
	enum SubscriptionType subscriptionType,
	ListChangeCallback list_change_callback,
	void* cookie, 
	void** subscription_handle);

int p9mdi_subscribe_instrument_trades(
	struct P9MDI_CONNECTION* connection,
	const char* exchange,
	const char* symbol,
	enum SubscriptionType subscriptionType,
	ListChangeCallback list_change_callback,
	void* cookie, 
	void** subscription_handle);

int p9mdi_subscribe_instrument_properties(
	struct P9MDI_CONNECTION* connection, 
	const char* exchange,
	const char* symbol,
	enum SubscriptionType subscriptionType,
	FieldChangeCallback field_change_callback,
	void* cookie, 
	void** subscription_handle);

int p9mdi_unsubscribe(struct P9MDI_CONNECTION* connection, void* subscription_handle);

int p9mdi_dispatch_pending_events(struct P9MDI_CONNECTION* connection);