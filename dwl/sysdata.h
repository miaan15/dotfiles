#include <alloca.h>
#include <alsa/asoundlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

static FILE *bat_fd = NULL;

void sysdata_init() {
    // battery
    if (bat_fd) {
        fclose(bat_fd);
        bat_fd = NULL;
    }
    bat_fd = fopen("/sys/class/power_supply/BAT0/capacity", "r");
    if (!bat_fd) { bat_fd = fopen("/sys/class/power_supply/BAT1/capacity", "r"); }
}

void sysdata_cleanup() {
    // battery
    if (bat_fd) {
        fclose(bat_fd);
        bat_fd = NULL;
    }
}

void getvolume(char *str) {
    snd_mixer_t *handle = NULL;
    snd_mixer_selem_id_t *sid = NULL;
    snd_mixer_elem_t *elem = NULL;

    long vol = 0, min = 0, max = 0;
    int switch_val = 1;

    // try load mixer
    if (snd_mixer_open(&handle, 0) < 0 ||
        snd_mixer_attach(handle, "default") < 0 ||
        snd_mixer_selem_register(handle, NULL, NULL) < 0 ||
        snd_mixer_load(handle) < 0) {
        goto error;
    }

    // mixer
    snd_mixer_selem_id_alloca(&sid);
    snd_mixer_selem_id_set_index(sid, 0);
    snd_mixer_selem_id_set_name(sid, "Master");
    elem = snd_mixer_find_selem(handle, sid);
    if (!elem) { goto error; }

    // if mute
    if (snd_mixer_selem_has_playback_switch(elem)) {
        snd_mixer_selem_get_playback_switch(elem, SND_MIXER_SCHN_FRONT_LEFT, &switch_val);
        if (switch_val == 0) {
            strcpy(str, "M");
            snd_mixer_close(handle);
            return;
        }
    }

    // read volume
    if (snd_mixer_selem_get_playback_volume_range(elem, &min, &max) < 0 ||
        snd_mixer_selem_get_playback_volume(elem, SND_MIXER_SCHN_FRONT_LEFT, &vol) < 0) {
        goto error;
    }

    long percent = (max > min) ? ((vol - min) * 100 / (max - min)) : 0;

    // to string
    if (percent >= 100) {
        strcpy(str, ">>");
    } else {
        sprintf(str, "%02ld", percent);
    }

    snd_mixer_close(handle);
    return;

error:
    if (handle) {
        snd_mixer_close(handle);
    }
    strcpy(str, "--");
}

#include <time.h>

void gettime(char *str) {
    time_t rawtime;
    struct tm *timeinfo;

    time(&rawtime);
    timeinfo = localtime(&rawtime);

    if (!timeinfo) {
        sprintf(str, "--");
        return;
    }

    sprintf(str, "%02d:%02d", timeinfo->tm_hour, timeinfo->tm_min);
}

void getbattery(char *str) {
    int cap = -1;

    if (!bat_fd) {
        strcpy(str, "--");
        return;
    }

    rewind(bat_fd);
    fflush(bat_fd);

    if (fscanf(bat_fd, "%d", &cap) != 1) {
        strcpy(str, "--");
        return;
    }

    if (cap >= 100) {
        strcpy(str, "F");
    } else if (cap < 0) {
        strcpy(str, "--");
    } else {
        sprintf(str, "%02d", cap);
    }
}
