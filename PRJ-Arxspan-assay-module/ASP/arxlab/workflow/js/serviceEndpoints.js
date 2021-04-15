var configServiceEndpoints = {
    REQUEST_TYPES: "/requesttypes",
    REQUEST_TYPES_BY_PERMISSION_TYPE: "/requesttypes/requestTypeNamesByPermissionType",
    REQUEST_TYPES_UPSERT: "/requesttypes/upsert",
    REQUEST_ITEM_TYPES: "/requestitemtypes",
    REQUEST_ITEM_TYPES_UPSERT: "/requestitemtypes/upsert",
    DROPDOWNS: "/dropdowns",
    FIELDS: "/fields",
    CODES: "/codes",
    DATA_TYPES: "/datatypes",
    IS_CURRENT_TYPE: "/requesttypes/isLatestVersion",
    GET_REQUEST_TYPE_FIELD_PRIORITY_OPTIONS: (requestTypeId) => `/requesttypes/${requestTypeId}/fields/priorityOptions`,
    GET_ALLOWED_APPS: `/codes/allowedApplications`,
    GET_VENDOR_ENDPOINT: (applicationTypeId) => `/requesttypes/VendorCustomAttributes/${applicationTypeId}`,
};

var appServiceEndpoints = {
    REQUESTS: `/requests`,
    REQUEST_STRUCTURES: "/requests/jChemImages",
    GET_REQUESTS: (requestId) => `/requests/${requestId}`,
    GET_REQUESTS_REVISION: (requestId, revisionId) => `${appServiceEndpoints.GET_REQUESTS(requestId)}/revision/${revisionId}`,
    REQUEST_NAME: (requestId) => `${appServiceEndpoints.GET_REQUESTS(requestId)}/requestName`,
    QUEUEABLE_REQUESTS: (requestTypeId) => `/requests/requestTypes/${requestTypeId}/queueable`,
    CHECK_REQUESTS_BY_CDID: (requestTypeId, cdId) => `/requests/requestTypes/${requestTypeId}/cdId/${cdId}`,
    GET_HAS_USER_MADE_REQUESTS: "/requests/hasUserMadeRequests",
    SEARCH: "/requests/search",
    CHECK_ASSIGNED_ORDER_LOCK: "/requests/checkAssignedOrderLock",
    TRANS_ASSIGNED_ORDER: "/requests/updateDraftAssignedOrder",
    TRANS_REQUESTED_ORDER: "/requests/updateDraftRequestedOrder",
    COMMIT_DRAFT_ASSIGNED_ORDER: "/requests/commitDraftAssignedOrder",
    COMMIT_DRAFT_REQUESTED_ORDER: "/requests/commitDraftRequestedOrder",
    CLEAR_ASSIGNED_ORDER: "/requests/clearDraftAssignedOrder",
    CLEAR_REQUESTED_ORDER: "/requests/clearDraftRequestedOrder",
    CHECK_DRAFT_REQUESTED_ORDER: (requestTypeId) => `/requests/requestTypes/${requestTypeId}/hasDraftRequestedOrder`,
    ELN_FIELD_UPDATE: "/requests/elnFieldUpdate"
};

var notificationServiceEndpoints = {
    UNREAD_NOTIFICATIONS: "/BrowserNotifications/not-read",
    UNREAD_NOTIFICATIONS_COUNT: "/BrowserNotifications/not-read-count",
    HEALTH_CHECK: "/healthcheck"
};

var linkServiceEndpoints = {
    GET_LINK: (id) => `/links/${id}`,
    GET_LINKS_BY_IDS: `/links`,
    GET_PARENT_LINKS: (parentTypeId, parentId) => `/links/parentTypeId/${parentTypeId}/parentId/${parentId}`,
    DELETE: (id) => `/links/${id}`,
    POST: `/Links`,
};

var workflowServiceEndpoints = {
    PRESAVE: "/workflow/preSave",
    POSTSAVE: "/workflow/postSave",
    HEALTH_CHECK: "/healthcheck"
};