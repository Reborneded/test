# app/services/settings_service.py
import json
import structlog
from typing import Any, Optional
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.database.models.system_settings import SystemSetting

logger = structlog.get_logger(__name__)

class SettingsService:
    def __init__(self, session: AsyncSession):
        self.session = session
        self._cache = {}

    async def get_setting(self, key: str, default: Any = None) -> Any:
        """Получить значение настройки из кэша или базы данных."""
        if key in self._cache:
            return self._cache[key]

        stmt = select(SystemSetting).where(SystemSetting.key == key)
        result = await self.session.execute(stmt)
        setting = result.scalar_one_or_none()

        if setting:
            # Десериализуем значение из JSON
            value = json.loads(setting.value)
            self._cache[key] = value
            return value
        return default

    async def set_setting(self, key: str, value: Any, value_type: str) -> None:
        """Установить значение настройки, обновив базу данных и сбросив кэш."""
        # Инвалидируем кэш
        self._cache.pop(key, None)

        stmt = select(SystemSetting).where(SystemSetting.key == key)
        result = await self.session.execute(stmt)
        setting = result.scalar_one_or_none()

        if setting:
            setting.value = json.dumps(value)
            setting.type = value_type
        else:
            new_setting = SystemSetting(
                key=key,
                value=json.dumps(value),
                type=value_type
            )
            self.session.add(new_setting)

        await self.session.commit()
        logger.info(f"Настройка {key} обновлена до {value}")
