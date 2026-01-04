import { Controller, Get } from '@nestjs/common';
import { Public } from '../auth/decorators/public.decorator';

@Controller('health')
export class HealthController {
  @Public()
  @Get()
  check() {
    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      memory: process.memoryUsage(),
    };
  }

  @Public()
  @Get('liveness')
  liveness() {
    return { status: 'alive' };
  }

  @Public()
  @Get('readiness')
  readiness() {
    return { status: 'ready' };
  }
}
