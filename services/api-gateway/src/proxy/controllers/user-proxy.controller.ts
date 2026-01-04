import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Headers,
  UseGuards,
  Req,
} from '@nestjs/common';
import { ThrottlerGuard } from '@nestjs/throttler';
import { ConfigService } from '@nestjs/config';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { ProxyService } from '../services/proxy.service';

@Controller('users')
@UseGuards(ThrottlerGuard, JwtAuthGuard)
export class UserProxyController {
  private readonly userServiceUrl: string;

  constructor(
    private readonly proxyService: ProxyService,
    private readonly configService: ConfigService,
  ) {
    this.userServiceUrl = this.configService.get('USER_SERVICE_URL');
  }

  @Get()
  async findAll(@Headers() headers: any) {
    return this.proxyService.forwardRequest(
      this.userServiceUrl,
      '/users',
      'GET',
      null,
      headers,
    );
  }

  @Get(':id')
  async findOne(@Param('id') id: string, @Headers() headers: any) {
    return this.proxyService.forwardRequest(
      this.userServiceUrl,
      `/users/${id}`,
      'GET',
      null,
      headers,
    );
  }

  @Post()
  async create(@Body() body: any, @Headers() headers: any) {
    return this.proxyService.forwardRequest(
      this.userServiceUrl,
      '/users',
      'POST',
      body,
      headers,
    );
  }

  @Put(':id')
  async update(
    @Param('id') id: string,
    @Body() body: any,
    @Headers() headers: any,
  ) {
    return this.proxyService.forwardRequest(
      this.userServiceUrl,
      `/users/${id}`,
      'PUT',
      body,
      headers,
    );
  }

  @Delete(':id')
  async remove(@Param('id') id: string, @Headers() headers: any) {
    return this.proxyService.forwardRequest(
      this.userServiceUrl,
      `/users/${id}`,
      'DELETE',
      null,
      headers,
    );
  }
}
