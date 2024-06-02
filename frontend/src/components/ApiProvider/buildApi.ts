import { isArray, isObject, isString } from 'lodash';
import type { Api, AnnouncementPatchData, CurrentUserAnnouncement, CurrentUserAnnouncementDetails, SignInApiResult } from './Api';

const errorType = (parsedBody: unknown): string => {
  if (!isObject(parsedBody)) {
    return 'unkown';
  } 
  if(!('error' in parsedBody)) {
    return 'unknown';
  }
  if (!isString(parsedBody.error)) {
    return 'unknown';
  }
  return parsedBody.error;
}

const buildApi = (isAccessTokenSet: () => boolean, getAccessToken: () => string) => {
  const extendHeadersWithAccessToken = (headers: Record<string, string>) => {
    if (!isAccessTokenSet()) {
      return headers;
    }
    return { ...headers, 'Authorization': 'Bearer ' + getAccessToken() };
  }

  const callSignIn = async (email: string, password: string): Promise<SignInApiResult> => {
    const response = await fetch('http://localhost:3000/sign_in', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ email, password })
    });
    if (response.status !== 200) {
      return { success: false };
    }
    const json = await response.json();
    return { success: true, accessToken: String(json.accessToken) };
  }

  const callSignUp = async (email: string, password: string): Promise<'success' | 'duplicated-email-error' | 'error'> => {
    const response = await fetch('http://localhost:3000/sign_up', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ email, password })
    });
    if (response.status === 200) {
      return 'success';
    }
    if (response.status === 400) {
      const parsedBody = await response.json(); 
      if (errorType(parsedBody) === 'duplicated-email') {
        return 'duplicated-email-error';
      }
      return 'error';
    }
    return 'error';
  }

  const normaliseLocation = (location: unknown): { latitude: number, longitude: number } => {
    if (!isObject(location)) {
      throw new Error('object expected');
    }
    if (!('latitude' in location)) {
      throw new Error('latitude is missing');
    }
    if (!('longitude' in location)) {
      throw new Error('longitude is missing');
    }
    return {
      latitude: Number(location.latitude),
      longitude: Number(location.longitude),
    };
  }

  const normaliseCurrentUserAnnouncementDetails = (announcement: unknown): CurrentUserAnnouncementDetails => {
    if (!isObject(announcement)) {
      throw new Error('object expected');
    }
    if (!('title' in announcement)) {
      throw new Error('title is missing');
    }
    if (!('draft' in announcement)) {
      throw new Error('draft is missing');
    }
    if (!('content' in announcement)) {
      throw new Error('content is missing');
    }
    if (!('location' in announcement)) {
      throw new Error('location is missing');
    }
    return {
      published: !announcement.draft,
      title: String(announcement.title),
      content: String(announcement.content),
      location: normaliseLocation(announcement.location),
    };
  };

  const normaliseCurrentUserAnnouncement = (announcement: unknown): CurrentUserAnnouncement => {
    if (!isObject(announcement)) {
      throw new Error('object expected');
    }
    if (!('id' in announcement)) {
      throw new Error('id is missing');
    }
    if (!('title' in announcement)) {
      throw new Error('title is missing');
    }
    if (!('draft' in announcement)) {
      throw new Error('draft is missing');
    }
    return {
      id: String(announcement.id),
      title: String(announcement.title),
      published: !announcement.draft
    };
  };

  const parseCurrentUserAnnouncmentsJson = (json: unknown): CurrentUserAnnouncement[] => {
    if (!isArray(json)) {
      throw new Error('array expected');
    }
    return json.map(normaliseCurrentUserAnnouncement);
  }

  const loadCurrentUserAnnouncements = async (): Promise<CurrentUserAnnouncement[]> => {
    const response = await fetch('http://localhost:3000/users/me/announcements', {
      method: 'GET',
      headers: extendHeadersWithAccessToken({
        'Content-Type': 'application/json',
      }),
    });
    if (response.status !== 200) {
      throw new Error('something went wrong');
    }
    return parseCurrentUserAnnouncmentsJson(await response.json());
  }

  const loadCurrentUserAnnouncement = async (id: string): Promise<CurrentUserAnnouncementDetails> => {
    const response = await fetch(`http://localhost:3000/users/me/announcements/${id}`, {
      method: 'GET',
      headers: extendHeadersWithAccessToken({
        'Content-Type': 'application/json',
      }),
    });
    if (response.status !== 200) {
      throw new Error('something went wrong');
    }
    return normaliseCurrentUserAnnouncementDetails(await response.json());
  }

  const callNewAnnouncement = async (): Promise<void> => {
    const response = await fetch('http://localhost:3000/users/me/announcements', {
      method: 'POST',
      headers: extendHeadersWithAccessToken({
        'Content-Type': 'application/json',
      }),
    });
    if (response.status !== 200) {
      throw new Error('something went wrong');
    }
  }

  const patchAnnouncement = async (id: string, data: AnnouncementPatchData): Promise<void> => {
    const response = await fetch('http://localhost:3000/users/me/announcements/' + id, {
      method: 'PATCH',
      headers: extendHeadersWithAccessToken({
        'Content-Type': 'application/json',
      }),
      body: JSON.stringify({
        title: data.title,
        content: data.content,
        location: data.location,
      }),
    });
    if (response.status !== 200) {
      throw new Error('something went wrong');
    }
  }

  const api: Api = {
    callSignIn,
    callSignUp,
    loadCurrentUserAnnouncements,
    loadCurrentUserAnnouncement,
    callNewAnnouncement,
    patchAnnouncement
  };

  return api;
}

export default buildApi;

