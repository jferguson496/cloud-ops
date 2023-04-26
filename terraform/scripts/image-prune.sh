#!/usr/bin/env bash
set -e

PERCENT_THRESHOLD=60
PERCENT_THRESHOLD_CRIT=85
DOCKER_DIR=$(docker info 2>&1 | grep 'Docker Root Dir' | awk -F ':' '{ print $2 }')
SPACE_PERCENT_USED=$(df ${DOCKER_DIR} | awk '{ print $5 }' | tail -n 1| cut -d'%' -f1)
INODE_PERCENT_USED=$(df -i ${DOCKER_DIR} | awk '{ print $5 }' | tail -n 1| cut -d'%' -f1)

if [ "${SPACE_PERCENT_USED}" -gt "${PERCENT_THRESHOLD}" ] || [ "${INODE_PERCENT_USED}" -gt "${PERCENT_THRESHOLD}" ]; then
  docker image prune -af > /dev/null 2>&1
  docker builder prune -af --filter=unused-for=6h > /dev/null 2>&1
fi

if [ "${SPACE_PERCENT_USED}" -gt "${PERCENT_THRESHOLD_CRIT}" ] || [ "${INODE_PERCENT_USED}" -gt "${PERCENT_THRESHOLD_CRIT}" ]; then
  docker system prune -af > /dev/null 2>&1
fi