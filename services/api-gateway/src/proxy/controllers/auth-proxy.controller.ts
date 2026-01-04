import {
  Controller,
  Post,
  Body,
  Headers,
  Req,
  UseGuards,
} from '@nestjs/common';
import { ThrottlerGuard } from '@nestjs/throttler';
import { ConfigService } from '@nestjs/config';
import { ProxyService } from '../services/proxy.service';
import { Public } from '../../auth/decorators/public.decorator';

@Controller('auth')
@UseGuards(ThrottlerGuard)
export class AuthProxyController {
  private readonly authServiceUrl: string;

  constructor(
    private readonly proxyService: ProxyService,
    private readonly configService: ConfigService,
  ) {
    this.authServiceUrl = this.configService.get('AUTH_SERVICE_URL');
  }

  @Public()
  @Post('register')
  async register(@Body() body: any) {
    return this.proxyService.forwardRequest(
      this.authServiceUrl,
      '/auth/register',
      'POST',
      body,
    );
  }

  @Public()
  @Post('login')
  async login(@Body() body: any) {
    return this.proxyService.forwardRequest(
      this.authServiceUrl,
      '/auth/login',
      'POST',
      body,
    );
  }

  @Post('refresh')
  async refresh(@Body() body: any, @Headers() headers: any) {
    return this.proxyService.forwardRequest(
      this.authServiceUrl,
      '/auth/refresh',
      'POST',
      body,
      headers,
    );
  }

  @Post('validate')
  async validate(@Body() body: any) {
    return this.proxyService.forwardRequest(
      this.authServiceUrl,
      '/auth/validate',
      'POST',
      body,
    );
  }
}
