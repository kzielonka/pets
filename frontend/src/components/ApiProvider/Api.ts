export type SetAccessToken = (accessToken: string) => void;

export interface SignInApiResultSuccess {
  success: true;
  accessToken: string;
};

export interface SignInApiResultFailure {
  success: false;
};

export type SignInApiResult = SignInApiResultSuccess | SignInApiResultFailure;

export type SignInApi = (email: string, password: string) => Promise<SignInApiResult>;

export type SignUpApi = (email: string, password: string) => Promise<'success' | 'duplicated-email-error' | 'error'>;

export interface CurrentUserAnnouncement {
  id: string;
  title: string;
  published: boolean;
};

export interface CurrentUserAnnouncementDetails {
  title: string;
  content: string;
  location: {
    latitude: number;
    longitude: number;
  };
  published: boolean;
};

export interface AnnouncementPatchData {
  title: string;
  content: string;
  location: {
    latitude: number;
    longitude: number;
  };
}

export interface AnnouncementSearchItem {
  id: string;
  title: string;
  content: string;
}

export type LoadCurrentUserAnnouncementsApi = () => Promise<CurrentUserAnnouncement[]>;

export type LoadCurrentUserAnnouncementApi = (id: string) => Promise<CurrentUserAnnouncementDetails>;

export type PatchAnnouncementApi = (id: string, data: AnnouncementPatchData) => Promise<void>;

export type NewAnnouncementApi = () => Promise<void>;

export type PublishAnnouncementApi = (id: string) => Promise<void>;

export type UnpublishAnnouncementApi = (id: string) => Promise<void>;

export type SearchAnnouncementsApi = (latitude: number, longitude: number) => Promise<AnnouncementSearchItem[]>;

export interface Api {
  callSignIn: SignInApi;
  callSignUp: SignUpApi;
  loadCurrentUserAnnouncements: LoadCurrentUserAnnouncementsApi; 
  loadCurrentUserAnnouncement: LoadCurrentUserAnnouncementApi;
  patchAnnouncement: PatchAnnouncementApi;
  callNewAnnouncement: NewAnnouncementApi;
  publishAnnouncement: PublishAnnouncementApi;
  unpublishAnnouncement: UnpublishAnnouncementApi;
  searchAnnouncements: SearchAnnouncementsApi;
};
